module Occi
  module Parser
    module Ovf

      # Declaring Class constants for OVF XML namespaces (defined in OVF specification ver.1.1)
      OVF ="http://schemas.dmtf.org/ovf/envelope/1"
      RASD ="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData"
      VSSD ="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData"
      OVFENV="http://schemas.dmtf.org/ovf/environment/1"
      CIM ="http://schemas.dmtf.org/wbem/wscim/1/common"

      # @param [String] string
      # @param [Hash] files key value pairs of file names and paths to the file
      def self.collection(string, files={})
        collection = Occi::Collection.new
        doc = Nokogiri::XML(string)

        references = parse_references(doc, files)
        parse_storage(doc, references, collection)
        parse_network(doc, collection)
        parse_compute(doc, references, collection)

        collection
      end

      def self.parse_references(doc, files)
        references = {}

        doc.xpath('envelope:Envelope/envelope:References/envelope:File', 'envelope' => "#{OVF}").each do |file|
          href = URI.parse(file.attributes['href'].to_s)
          if href.relative?
            if files[href.to_s]
              references[file.attributes['id'].to_s] = 'file://' + files[href.to_s]
            else
              references[file.attributes['id'].to_s] = 'file://' + href.to_s
            end
          else
            references[file.attributes['id'].to_s] = href.to_s
          end
        end

        references
      end

      def self.parse_storage(doc, references, collection)
        doc.xpath('envelope:Envelope/envelope:DiskSection/envelope:Disk', 'envelope' => "#{OVF}").each do |disk|
          storage = Occi::Infrastructure::Storage.new
          storage.id ||= UUIDTools::UUID.random_create.to_s

          if disk.attributes['fileRef']
            storagelink = Occi::Infrastructure::Storagelink.new
            storagelink.id ||= UUIDTools::UUID.random_create.to_s
            storagelink.title = disk.attributes['fileRef'].to_s
            storagelink.target = references[disk.attributes['fileRef'].to_s]

            storage.title = disk.attributes['diskId'].to_s
            storage.links << storagelink
          else
            #OCCI accepts storage size in GB
            #OVF ver 1.1: The capacity of a virtual disk shall be specified by the ovf:capacity attribute with an xs:long integer
            #value. The default unit odf allocation shall be bytes. The optional string attribute
            #ovf:capacityAllocationUnits may be used to specify a particular unit of allocation.
            alloc_units = disk.attributes['capacityAllocationUnits'].to_s

            if alloc_units.empty?
              # The capacity is defined in bytes , convert to GB and pass it to OCCI
              capacity = disk.attributes['capacity'].to_s
              capacity =capacity.to_i
            else
              alloc_unit_bytes = self.alloc_units_bytes(alloc_units)
              capacity = self.calculate_capacity_bytes(disk.attributes['capacity'].to_s, alloc_unit_bytes)
            end

            capacity_gb = self.calculate_capacity_gb(capacity)
            storage.size = capacity_gb.to_s if capacity_gb
            storage.title = disk.attributes['diskId'].to_s if disk.attributes['diskId']
          end

          collection.resources << storage
        end
      end

      def self.parse_network(doc, collection)
        doc.xpath('envelope:Envelope/envelope:NetworkSection/envelope:Network', 'envelope' => "#{OVF}").each do |nw|
          network = Occi::Infrastructure::Network.new
          network.id ||= UUIDTools::UUID.random_create.to_s
          network.title = nw.attributes['name'].to_s

          collection.resources << network
        end
      end

      def self.parse_compute(doc, references, collection)
        # Iteration through all the virtual hardware sections,and a sub-iteration on each Item defined in the Virtual Hardware section
        doc.xpath('envelope:Envelope/envelope:VirtualSystem', 'envelope' => "#{OVF}").each do |virtsys|
          compute = Occi::Infrastructure::Compute.new
          compute.id ||= UUIDTools::UUID.random_create.to_s

          doc.xpath('envelope:Envelope/envelope:VirtualSystem/envelope:VirtualHardwareSection', 'envelope' => "#{OVF}").each do |virthwsec|
            compute.summary = virthwsec.xpath("item:Info/text()", 'item' => "#{RASD}").to_s

            parse_compute_resources(collection, compute, virthwsec)
          end

          collection.resources << compute
        end
      end

      def self.parse_compute_resources(collection, compute, virthwsec)
        virthwsec.xpath('envelope:Item', 'envelope' => "#{OVF}").each do |resource_alloc|
          resType = resource_alloc.xpath("item:ResourceType/text()", 'item' => "#{RASD}")

          case resType.to_s
          # 4 is the ResourceType for memory in the CIM_ResourceAllocationSettingData
          when "4" then
            Occi::Log.debug('calculating memory in gb ')
            alloc_units = resource_alloc.xpath("item:AllocationUnits/text()", 'item' => "#{RASD}").to_s

            Occi::Log.debug('allocated units in ovf file: ' + alloc_units)
            alloc_unit_bytes = self.alloc_units_bytes(alloc_units)
            capacity = self.calculate_capacity_bytes(resource_alloc.xpath("item:VirtualQuantity/text()", 'item' => "#{RASD}").to_s, alloc_unit_bytes)
            capacity_gb = self.calculate_capacity_gb(capacity)

            Occi::Log.debug('virtual quantity of memory configured in gb: ' + capacity_gb.to_s)
            compute.memory = capacity_gb
          #  compute.attributes.occi!.compute!.memory = resource_alloc.xpath("item:VirtualQuantity/text()", 'item' => "#{RASD}").to_s.to_i
          # 3 is the ResourceType for processor in the CIM_ResourceAllocationSettingData
          when "3" then
            compute.cores = resource_alloc.xpath("item:VirtualQuantity/text()", 'item' => "#{RASD}").to_s.to_i
          when "10" then
            id = resource_alloc.xpath("item:Connection/text()", 'item' => "#{RASD}").to_s
            network = collection.resources.select { |resource| resource.title == id }.first
            raise Occi::Errors::ParserInputError, "Network with id #{id} not found" unless network

            networkinterface = compute.networkinterface(network)
            networkinterface.title = resource_alloc.xpath("item:ElementName/text()", 'item' => "#{RASD}").to_s
          when "17" then
            # extract the mountpoint
            host_resource = resource_alloc.xpath("item:HostResource/text()", 'item' => "#{RASD}").to_s

            if host_resource.start_with? 'ovf:/disk/'
              id = host_resource.gsub('ovf:/disk/', '')
              storage = collection.resources.select { |resource| resource.title == id }.first
              raise Occi::Errors::ParserInputError, "Disk with id #{id} not found" unless storage
            elsif host_resource.start_with? 'ovf:/file/'
              raise Occi::Errors::ParserInputError, 'OVF files are not supported!'
              #id = host_resource.gsub('ovf:/file/', '')
              #storagelink.attributes.occi!.core!.target = references[id]
            end

            storagelink = compute.storagelink(storage)
            storagelink.title = resource_alloc.xpath("item:ElementName/text()", 'item' => "#{RASD}").to_s
          end

          ##Add the cpu architecture
          #system_sec                                      = virthwsec.xpath('envelope:System', 'envelope' => "#{OVF}")
          #virtsys_type                                    = system_sec.xpath('vssd_:VirtualSystemType/text()', 'vssd_' => "#{VSSD}")
          #compute.attributes.occi!.compute!.architecture = virtsys_type
        end
      end

      ####################Helper method for calculation of storage size based on allocation units configured###########

      def self.calculate_capacity_bytes(capacity, alloc_units_bytes)
        total_capacity_bytes = alloc_units_bytes * capacity.to_i
        total_capacity_bytes
      end


      def self.calculate_capacity_gb(capacity)
        capacity_gb = capacity.to_f/(2**30)
        capacity_gb
      end


      def self.alloc_units_bytes(alloc_units)
        units = alloc_units.split('*')
        #check units[1] is nil??
        units[1].strip!
        alloc_vars = units[1].split('^')
        alloc_units_bytes = (alloc_vars[0].to_i**alloc_vars[1].to_i)
        alloc_units_bytes
      end

      ###############End of Helper methods for OVF Parsing ##################################################################

    end
  end
end