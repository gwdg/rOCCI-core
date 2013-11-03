module Occi
  module Parser
    module Ovf

      # Declaring Class constants for OVF XML namespaces (defined in OVF specification ver.1.1)
      OVF ="http://schemas.dmtf.org/ovf/envelope/1"
      RASD ="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData"
      VSSD ="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData"
      OVFENV="http://schemas.dmtf.org/ovf/environment/1"
      CIM ="http://schemas.dmtf.org/wbem/wscim/1/common"

      class << self

        # @param [String] string
        # @param [Hash] files key value pairs of file names and paths to the file
        def collection(string, files={})
          collection = Occi::Collection.new
          doc = Nokogiri::XML(string)

          references = parse_references(doc, files)
          parse_storage(doc, references, collection)
          parse_network(doc, collection)
          parse_compute(doc, references, collection)

          collection
        end

        def parse_references(doc, files)
          references = {}

          doc.xpath('envelope:Envelope/envelope:References/envelope:File', 'envelope' => "#{OVF}").each do |file|
            href = URI.parse(file.attributes['href'].to_s)
            references[file.attributes['id'].to_s] = if href.relative?
              files[href.to_s] ? "file://#{files[href.to_s]}" : "file://#{href.to_s}"
            else
              href.to_s
            end
          end

          references
        end

        def parse_storage(doc, references, collection)
          doc.xpath('envelope:Envelope/envelope:DiskSection/envelope:Disk', 'envelope' => "#{OVF}").each do |disk|
            storage = Occi::Infrastructure::Storage.new

            if disk.attributes['fileRef']
              parse_storage_disk_file(disk, storage, references)
            else
              parse_storage_disk_alloc(disk, storage, references)
            end

            collection.resources << storage
          end

          collection
        end

        def parse_storage_disk_file(disk, storage, references)
          storagelink = Occi::Infrastructure::Storagelink.new
          storagelink.title = disk.attributes['fileRef'].to_s
          storagelink.target = references[disk.attributes['fileRef'].to_s]

          storage.title = disk.attributes['diskId'].to_s
          storage.links << storagelink

          storage
        end

        def parse_storage_disk_alloc(disk, storage)
          #OCCI accepts storage size in GB
          #OVF ver 1.1: The capacity of a virtual disk shall be specified by the ovf:capacity attribute with an xs:long integer
          #value. The default unit odf allocation shall be bytes. The optional string attribute
          #ovf:capacityAllocationUnits may be used to specify a particular unit of allocation.
          alloc_units = disk.attributes['capacityAllocationUnits'].to_s

          if alloc_units.empty?
            # The capacity is defined in bytes, convert to GB and pass it to OCCI
            capacity = disk.attributes['capacity'].to_s.to_i
          else
            alloc_unit_bytes = alloc_units_bytes(alloc_units)
            capacity = calculate_capacity_bytes(disk.attributes['capacity'].to_s, alloc_unit_bytes)
          end

          capacity_gb = calculate_capacity_gb(capacity)
          storage.size = capacity_gb.to_s if capacity_gb
          storage.title = disk.attributes['diskId'].to_s if disk.attributes['diskId']

          storage
        end

        def parse_network(doc, collection)
          doc.xpath('envelope:Envelope/envelope:NetworkSection/envelope:Network', 'envelope' => "#{OVF}").each do |nw|
            network = Occi::Infrastructure::Network.new
            network.title = nw.attributes['name'].to_s
            collection.resources << network
          end

          collection
        end

        def parse_compute(doc, references, collection)
          # Iteration through all the virtual hardware sections,and a sub-iteration on each Item defined in the Virtual Hardware section
          doc.xpath('envelope:Envelope/envelope:VirtualSystem', 'envelope' => "#{OVF}").each do |virtsys|
            compute = Occi::Infrastructure::Compute.new

            doc.xpath('envelope:Envelope/envelope:VirtualSystem/envelope:VirtualHardwareSection', 'envelope' => "#{OVF}").each do |virthwsec|
              compute.summary = virthwsec.xpath("item:Info/text()", 'item' => "#{RASD}").to_s
              parse_compute_resources(collection, compute, virthwsec)
            end

            collection.resources << compute
          end

          collection
        end

        def parse_compute_resources(collection, compute, virthwsec)
          virthwsec.xpath('envelope:Item', 'envelope' => "#{OVF}").each do |resource_alloc|
            resType = resource_alloc.xpath("item:ResourceType/text()", 'item' => "#{RASD}")

            case resType.to_s
            when "4" then
              # 4 is the ResourceType for memory in the CIM_ResourceAllocationSettingData
              parse_compute_memory(resource_alloc, compute)
            when "3" then
              # 3 is the ResourceType for processor in the CIM_ResourceAllocationSettingData
              compute.cores = resource_alloc.xpath("item:VirtualQuantity/text()", 'item' => "#{RASD}").to_s.to_i
            when "10" then
              # extract the network
              parse_compute_network(resource_alloc, compute, collection)
            when "17" then
              # extract the mountpoint
              parse_compute_storage(resource_alloc, compute, collection)
            end

            ##Add the cpu architecture
            #system_sec = virthwsec.xpath('envelope:System', 'envelope' => "#{OVF}")
            #compute.architecture = system_sec.xpath('vssd_:VirtualSystemType/text()', 'vssd_' => "#{VSSD}")
          end

          compute
        end

        def parse_compute_memory(resource_alloc, compute)
          alloc_units = resource_alloc.xpath("item:AllocationUnits/text()", 'item' => "#{RASD}").to_s

          alloc_unit_bytes = alloc_units_bytes(alloc_units)
          capacity = calculate_capacity_bytes(resource_alloc.xpath("item:VirtualQuantity/text()", 'item' => "#{RASD}").to_s, alloc_unit_bytes)
          capacity_gb = calculate_capacity_gb(capacity)

          compute.memory = capacity_gb
          # compute.attributes.occi!.compute!.memory = resource_alloc.xpath("item:VirtualQuantity/text()", 'item' => "#{RASD}").to_s.to_i

          compute
        end

        def parse_compute_network(resource_alloc, compute, collection)
          id = resource_alloc.xpath("item:Connection/text()", 'item' => "#{RASD}").to_s
          network = collection.resources.select { |resource| resource.title == id }.first
          raise Occi::Errors::ParserInputError, "Network with id #{id} not found" unless network

          networkinterface = compute.networkinterface(network)
          networkinterface.title = resource_alloc.xpath("item:ElementName/text()", 'item' => "#{RASD}").to_s

          compute
        end

        def parse_compute_storage(resource_alloc, compute, collection)
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

          compute
        end

        def calculate_capacity_bytes(capacity, alloc_units_bytes)
          total_capacity_bytes = alloc_units_bytes * capacity.to_i
          total_capacity_bytes
        end

        def calculate_capacity_gb(capacity)
          capacity_gb = capacity.to_f/(2**30)
          capacity_gb
        end

        def alloc_units_bytes(alloc_units)
          units = alloc_units.split('*')
          #check units[1] is nil??
          units[1].strip!
          alloc_vars = units[1].split('^')
          alloc_units_bytes = (alloc_vars[0].to_i**alloc_vars[1].to_i)
          alloc_units_bytes
        end

      end

    end
  end
end