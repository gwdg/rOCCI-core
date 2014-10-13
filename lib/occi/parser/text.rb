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
          resource.id = nil
          links = []

          block = Proc.new { |line|
            line.strip!
            case line
            when /^Category:/
              category = category(line)

              if category.kind_of? Occi::Core::Kind
                resource = Occi::Core::Resource.new(category.type_identifier)
                resource.kind = category
              end
              resource.mixins << category if category.kind_of? Occi::Core::Mixin
            when /^X-OCCI-Attribute:/
              resource.attributes.merge! attribute(line)
            when /^Link:/
              link = link_string(line, resource)

              if link.kind_of? Occi::Core::Link
                resource.links << link
                links << link
              elsif link.kind_of? Occi::Core::Action
                resource.actions << link
              else
                raise Occi::Errors::ParserInputError, "Could not recognize resource link! #{link.inspect}"
              end
            end
          }
          lines.respond_to?(:each) ? lines.each(&block) : lines.each_line(&block)

          if resource.kind_of?(Occi::Core::Resource) && !resource.empty?
            collection << resource
            links.each { |link| collection << link }
          end

          collection
        end

        def link(lines)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.link"
          collection = Occi::Collection.new
          link = Occi::Core::Link.new
          link.id = nil

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

          collection << link if link.kind_of?(Occi::Core::Link) && !link.empty?
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

          raise Occi::Errors::ParserInputError, "Could not match #{string.inspect}" unless match

          term = match[:term].downcase
          scheme = match[:scheme]
          title = match[:title]
          related = match[:rel].to_s.split(/\s+/)

          attributes = category_attributes(match[:attributes])
          actions = match[:actions].to_s.split
          location = match[:location]

          case match[:class]
          when 'kind'
            Occi::Log.debug "[#{self}] class #{match[:class].inspect} identified as kind"
            Occi::Core::Kind.new scheme, term, title, attributes, related, actions, location
          when 'mixin'
            Occi::Log.debug "[#{self}] class #{match[:class].inspect} identified as mixin"
            Occi::Core::Mixin.new scheme, term, title, attributes, related, actions, location
          when 'action'
            Occi::Log.debug "[#{self}] class #{match[:class].inspect} identified as action"
            Occi::Core::Action.new scheme, term, title, attributes
          else
            raise Occi::Errors::ParserInputError, "Category with class #{match[:class].inspect} not recognized in string: #{string}"
          end
        end

        def category_attributes(matched_attributes)
          attributes = Occi::Core::Attributes.new
          return attributes unless matched_attributes

          # TODO: find a better approach to fixing split
          matched_attributes.gsub! /\{(immutable|required)\s+(required|immutable)\}/, '{\1_\2}'

          matched_attributes.split.each do |attribute|
            attribute.gsub! /\{(immutable|required)_(required|immutable)\}/, '{\1 \2}'
            property_string = attribute[/#{REGEXP_ATTRIBUTE_DEF}/, -2]
            properties = Occi::Core::Properties.new

            if property_string
              properties.required = property_string.include?('required')
              properties.mutable = !property_string.include?('immutable')
            end

            name = attribute[/#{REGEXP_ATTRIBUTE_DEF}/, 1]
            attributes.merge! name.split('.').reverse.inject(properties) { |a, n| Occi::Core::Attributes.new(n => a) }
          end

          attributes
        end

        def attribute(string)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.attribute"
          # create regular expression from regexp string
          regexp = Regexp.new(REGEXP_ATTRIBUTE)
          # match string to regular expression
          match = regexp.match string

          raise Occi::Errors::ParserInputError, "Could not match #{string.inspect}" unless match

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

          raise Occi::Errors::ParserInputError, "Could not match #{string.inspect}" unless match

          if match[:uri].include?('?action=')
            link_string_action match
          else
            link_string_link match, source
          end
        end

        def link_string_action(match)
          scheme, term = match[:rel].split('#')
          Occi::Core::Action.new scheme, term
        end

        def link_string_link(match, source)
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
          regexp = Regexp.new '(\\s*'+REGEXP_ATTRIBUTE_REPR.to_s+')'
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

          raise Occi::Errors::ParserInputError, "Could not match #{string.inspect}" unless match

          match[:location]
        end

        def action(lines)
          Occi::Log.debug "[#{self}] Parsing through Occi::Parser::Text.action"
          collection = Occi::Collection.new
          action_instance = nil

          block = Proc.new { |line|
            line.strip!

            case line
            when /^Category:/
              action_instance = Occi::Core::ActionInstance.new
              action_instance.action = category(line)
            when /^X-OCCI-Attribute:/
              raise Occi::Errors::ParserInputError,
                    "Line #{line.inspect} arrived out of order!" unless action_instance
              action_instance.attributes.merge! attribute(line)
            end
          }
          lines.respond_to?(:each) ? lines.each(&block) : lines.each_line(&block)

          unless action_instance.blank?
            collection << action_instance
          end

          collection
        end

      end

    end
  end
end
