Dir[File.join(File.dirname(__FILE__), 'text', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi
  module Parser
    module Text

      class << self

        include Occi::Parser::Text::Constants

        def categories(lines)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.categories"
          collection = Occi::Collection.new

          block = Proc.new { |line|
            line.strip!
            category = category(line) if line.start_with? 'Category:'
            collection << category if category.kind_of? Occi::Core::Category
          }

          lines.respond_to?(:each) ? lines.each(&block) : lines.each_line(&block)
          collection
        end

        def resource(lines)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.resource"
          collection = Occi::Collection.new
          resource = Occi::Core::Resource.new

          block = Proc.new { |line|
            line.strip!
            case line
              when /^Category:/
                category = category(line)
                resource.kind = category if category.kind_of? Occi::Core::Kind
                resource.mixins << category if category.kind_of? Occi::Core::Mixin
              when /^X-OCCI-Attribute:/
                resource.attributes.merge! attribute(line)
              when /^Link:/
                link = link_string(line, resource)
                resource.links << link
                collection << link
            end
          }
          lines.respond_to?(:each) ? lines.each(&block) : lines.each_line(&block)

          collection << resource if resource.kind_of? Occi::Core::Resource
          collection
        end

        def link(lines)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.link"
          collection = Occi::Collection.new
          link = Occi::Core::Link.new

          block = Proc.new { |line|
            line.strip!
            case line
              when /^Category:/
                category = category(line)
                link.kind = category if category.kind_of? Occi::Core::Kind
                link.mixins << category if category.kind_of? Occi::Core::Mixin
              when /^X-OCCI-Attribute:/
                link.attributes.merge! attribute(line)
            end
          }
          lines.respond_to?(:each) ? lines.each(&block) : lines.each_line(&block)

          collection << link if link.kind_of? Occi::Core::Link
          collection
        end

        def locations(lines)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.locations"
          locations = []

          block = Proc.new { |line|
            line.strip!
            locations << location(line) if line.start_with? 'X-OCCI-Location:'
          }
          lines.respond_to?(:each) ? lines.each(&block) : lines.each_line(&block)

          locations
        end

        def category(string)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.category"
          # create regular expression from regexp string
          regexp = Regexp.new( Occi::Settings.compatibility ?  REGEXP_CATEGORY : REGEXP_CATEGORY_STRICT )
          # match string to regular expression
          match = regexp.match string

          raise Occi::Errors::ParserInputError, "could not match #{string}" unless match

          term = match[:term].downcase
          scheme = match[:scheme]
          title = match[:title]
          related = match[:rel].to_s.split

          attributes = Occi::Core::Attributes.new
          if match[:attributes]
            match[:attributes].split.each do |attribute|
              property_string = attribute[/#{REGEXP_ATTRIBUTE_DEF}/, -2]
              properties = Occi::Core::Properties.new

              if property_string
                properties.required = true if property_string.include? 'required'
                properties.mutable = false if property_string.include? 'immutable'
              end

              name = attribute[/#{REGEXP_ATTRIBUTE_DEF}/, 1]
              attributes.merge! name.split('.').reverse.inject(properties) { |a, n| Occi::Core::Attributes.new(n => a) }
            end
          end
          actions = match[:actions].to_s.split
          location = match[:location]

          case match[:class]
            when 'kind'
              Occi::Log.debug "[#{self}] class #{match[:class]} identified as kind"
              Occi::Core::Kind.new scheme, term, title, attributes, related, actions, location
            when 'mixin'
              Occi::Log.debug "[#{self}] class #{match[:class]} identified as mixin"
              Occi::Core::Mixin.new scheme, term, title, attributes, related, actions, location
            when 'action'
              Occi::Log.debug "[#{self}] class #{match[:class]} identified as action"
              Occi::Core::Action.new scheme, term, title, attributes
            else
              raise Occi::Errors::ParserInputError, "Category with class #{match[:class]} not recognized in string: #{string}"
          end
        end

        def attribute(string)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.attribute"
          # create regular expression from regexp string
          regexp = Regexp.new(REGEXP_ATTRIBUTE)
          # match string to regular expression
          match = regexp.match string

          raise Occi::Errors::ParserInputError, "could not match #{string}" unless match

          value = match[:string] if match[:string]

          if match[:number]
            match[:number].include?('.') ? value = match[:number].to_f : value = match[:number].to_i
          end

          value = match[:bool] == "true" if match[:bool]
          Occi::Core::Attributes.split match[:name] => value
        end

        def link_string(string, source)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.link_string"
          # create regular expression from regexp string
          regexp = Regexp.new( Occi::Settings.compatibility ? REGEXP_LINK : REGEXP_LINK_STRICT )
          # match string to regular expression
          match = regexp.match string

          raise Occi::Errors::ParserInputError, "could not match #{string}" unless match

          target = match[:uri]
          rel = match[:rel]
          if match[:category].blank?
            kind = Occi::Core::Link.kind
          else
            categories = match[:category].split
            kind = categories.shift
            mixins = categories
          end
          actions = nil
          location = match[:self]

          # create an array of the list of attributes
          attributes = []
          regexp=Regexp.new '(\\s*'+REGEXP_ATTRIBUTE_REPR.to_s+')'
          attr_line = match[:attributes].sub(/^\s*;\s*/, ' ')
          attributes = attr_line.scan(regexp).collect {|matches| matches.first}

          # parse each attribute and create an OCCI Attribute object from it
          attributes = attributes.inject(Hashie::Mash.new) { |hsh, attribute|
            hsh.merge!(Occi::Parser::Text.attribute("X-OCCI-Attribute: #{attribute}"))
          }
          Occi::Core::Link.new kind, mixins, attributes, actions, rel, target, source, location
        end

        def location(string)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.location"
          # create regular expression from regexp string
          regexp = Regexp.new(REGEXP_LOCATION)
          # match string to regular expression
          match = regexp.match string

          raise Occi::Errors::ParserInputError, "could not match #{string}" unless match

          match[:location]
        end

      end

    end
  end
end
