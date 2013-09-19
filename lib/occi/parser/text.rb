module Occi
  module Parser
    module Text

      # Regular expressions
      REGEXP_QUOTED_STRING = /([^"\\]|\\.)*/
      REGEXP_LOALPHA = /[a-z]/
      REGEXP_DIGIT = /[0-9]/
      REGEXP_INT = /#{REGEXP_DIGIT}+/
      REGEXP_FLOAT = /#{REGEXP_INT}\.#{REGEXP_INT}/
      REGEXP_NUMBER = /#{REGEXP_FLOAT}|#{REGEXP_INT}/
      REGEXP_BOOL = /true|false/

      # Regular expressions for OCCI
      if Occi::Settings.compatibility
        # Compatibility with terms starting with a number
        REGEXP_TERM = /(#{REGEXP_LOALPHA}|#{REGEXP_DIGIT})(#{REGEXP_LOALPHA}|#{REGEXP_DIGIT}|-|_)*/
      else
        REGEXP_TERM = /#{REGEXP_LOALPHA}(#{REGEXP_LOALPHA}|#{REGEXP_DIGIT}|-|_)*/
      end
      REGEXP_SCHEME = /#{URI::ABS_URI_REF}#/
      REGEXP_TYPE_IDENTIFIER = /#{REGEXP_SCHEME}#{REGEXP_TERM}/
      REGEXP_CLASS = /action|mixin|kind/

      REGEXP_ATTR_COMPONENT = /#{REGEXP_LOALPHA}(#{REGEXP_LOALPHA}|#{REGEXP_DIGIT}|-|_)*/
      REGEXP_ATTRIBUTE_NAME = /#{REGEXP_ATTR_COMPONENT}(\.#{REGEXP_ATTR_COMPONENT})*/
      REGEXP_ATTRIBUTE_PROPERTY = /immutable|required/
      REGEXP_ATTRIBUTE_DEF = /(#{REGEXP_ATTRIBUTE_NAME})(\{#{REGEXP_ATTRIBUTE_PROPERTY}(\s+#{REGEXP_ATTRIBUTE_PROPERTY})*\})?/
      REGEXP_ATTRIBUTE_LIST = /#{REGEXP_ATTRIBUTE_DEF}(\s+#{REGEXP_ATTRIBUTE_DEF})*/
      REGEXP_ATTRIBUTE_REPR = /#{REGEXP_ATTRIBUTE_NAME}=("#{REGEXP_QUOTED_STRING}"|#{REGEXP_NUMBER}|#{REGEXP_BOOL})/

      REGEXP_ACTION = /#{REGEXP_TYPE_IDENTIFIER}/
      REGEXP_ACTION_LIST = /#{REGEXP_ACTION}(\s+#{REGEXP_ACTION})*/

      REGEXP_RESOURCE_TYPE = /#{REGEXP_TYPE_IDENTIFIER}(\s+#{REGEXP_TYPE_IDENTIFIER})*/
      REGEXP_LINK_INSTANCE = /#{URI::URI_REF}/
      REGEXP_LINK_TYPE = /#{REGEXP_TYPE_IDENTIFIER}(\s+#{REGEXP_TYPE_IDENTIFIER})*/

      # Regular expression for OCCI Categories
      if Occi::Settings.compatibility
        REGEXP_CATEGORY = "Category:\\s*(?<term>#{REGEXP_TERM})" << # term (mandatory)
            ";\\s*scheme=\"(?<scheme>#{REGEXP_SCHEME})#{REGEXP_TERM}?\"" << # scheme (mandatory)
            ";\\s*class=\"?(?<class>#{REGEXP_CLASS})\"?" << # class (mandatory)
            "(;\\s*title=\"(?<title>#{REGEXP_QUOTED_STRING})\")?" << # title (optional)
            "(;\\s*rel=\"(?<rel>#{REGEXP_TYPE_IDENTIFIER})\")?"<< # rel (optional)
            "(;\\s*location=\"(?<location>#{URI::URI_REF})\")?" << # location (optional)
            "(;\\s*attributes=\"(?<attributes>#{REGEXP_ATTRIBUTE_LIST})\")?" << # attributes (optional)
            "(;\\s*actions=\"(?<actions>#{REGEXP_ACTION_LIST})\")?" << # actions (optional)
            ';?' # additional semicolon at the end (not specified, for interoperability)
      else
        REGEXP_CATEGORY = "Category:\\s*(?<term>#{REGEXP_TERM})" << # term (mandatory)
            ";\\s*scheme=\"(?<scheme>#{REGEXP_SCHEME})\"" << # scheme (mandatory)
            ";\\s*class=\"(?<class>#{REGEXP_CLASS})\"" << # class (mandatory)
            "(;\\s*title=\"(?<title>#{REGEXP_QUOTED_STRING})\")?" << # title (optional)
            "(;\\s*rel=\"(?<rel>#{REGEXP_TYPE_IDENTIFIER})\")?"<< # rel (optional)
            "(;\\s*location=\"(?<location>#{URI::URI_REF})\")?" << # location (optional)
            "(;\\s*attributes=\"(?<attributes>#{REGEXP_ATTRIBUTE_LIST})\")?" << # attributes (optional)
            "(;\\s*actions=\"(?<actions>#{REGEXP_ACTION_LIST})\")?" << # actions (optional)
            ';?' # additional semicolon at the end (not specified, for interoperability)
      end

      # Regular expression for OCCI Link Instance References
      if Occi::Settings.compatibility
        REGEXP_LINK = "Link:\\s*\\<(?<uri>#{URI::URI_REF})\\>" << # uri (mandatory)
            ";\\s*rel=\"(?<rel>#{REGEXP_RESOURCE_TYPE})\"" << # rel (mandatory)
            "(;\\s*self=\"(?<self>#{REGEXP_LINK_INSTANCE})\")?" << # self (optional)
            "(;\\s*category=\"(?<category>(;?\\s*(#{REGEXP_LINK_TYPE}))+)\")?" << # category (optional)
            "(?<attributes>(;?\\s*(#{REGEXP_ATTRIBUTE_REPR}))*)" << # attributes (optional)
            ';?' # additional semicolon at the end (not specified, for interoperability)
      else
        REGEXP_LINK = "Link:\\s*\\<(?<uri>#{URI::URI_REF})\\>" << # uri (mandatory)
            ";\\s*rel=\"(?<rel>#{REGEXP_RESOURCE_TYPE})\"" << # rel (mandatory)
            "(;\\s*self=\"(?<self>#{REGEXP_LINK_INSTANCE})\")?" << # self (optional)
            "(;\\s*category=\"(?<category>(;?\\s*(#{REGEXP_LINK_TYPE}))+)\")?" << # category (optional)
            "(?<attributes>(;\\s*(#{REGEXP_ATTRIBUTE_REPR}))*)" << # attributes (optional)
            ';?' # additional semicolon at the end (not specified, for interoperability)
      end

      # Regular expression for OCCI Entity Attributes
      REGEXP_ATTRIBUTE = "X-OCCI-Attribute:\\s*(?<name>#{REGEXP_ATTRIBUTE_NAME})=(\"(?<string>#{REGEXP_QUOTED_STRING})\"|(?<number>#{REGEXP_NUMBER})|(?<bool>#{REGEXP_BOOL}))" <<
          ';?' # additional semicolon at the end (not specified, for interoperability)

      # Regular expression for OCCI Location
      REGEXP_LOCATION = "X-OCCI-Location:\\s*(?<location>#{URI::URI_REF})" <<
          ';?' # additional semicolon at the end (not specified, for interoperability)


      def self.categories(lines)
        collection = Occi::Collection.new
        lines.each do |line|
          line.strip!
          category = self.category(line) if line.start_with? 'Category:'
          collection << category if category.kind_of? Occi::Core::Category
        end
        collection
      end

      def self.resource(lines)
        collection = Occi::Collection.new
        resource = Occi::Core::Resource.new
        lines.each do |line|
          line.strip!
          case line
            when /^Category:/
              category = self.category(line)
              resource.kind = category if category.kind_of? Occi::Core::Kind
              resource.mixins << category if category.kind_of? Occi::Core::Mixin
            when /^X-OCCI-Attribute:/
              resource.attributes.merge! self.attribute(line)
            when /^Link:/
              link = self.link_string(line, resource)
              resource.links << link
              collection << link
          end
        end
        collection << resource if resource.kind_of? Occi::Core::Resource
        collection
      end

      def self.link(lines)
        collection = Occi::Collection.new
        link = Occi::Core::Link.new
        lines.each do |line|
          line.strip!
          case line
            when /^Category:/
              category = self.category(line)
              link.kind = category if category.kind_of? Occi::Core::Kind
              link.mixins << category if category.kind_of? Occi::Core::Mixin
            when /^X-OCCI-Attribute:/
              link.attributes.merge! self.attribute(line)
          end
        end
        collection << link if link.kind_of? Occi::Core::Link
        collection
      end

      def self.locations(lines)
        locations = []
        lines.each do |line|
          line.strip!
          locations << self.location(line) if line.start_with? 'X-OCCI-Location:'
        end
        locations
      end

      private

      def self.category(string)
        # create regular expression from regexp string
        regexp = Regexp.new(REGEXP_CATEGORY)
        # match string to regular expression
        match = regexp.match string

        raise "could not match #{string}" unless match

        term = match[:term]
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
            Occi::Core::Kind.new scheme, term, title, attributes, related, actions, location
          when 'mixin'
            Occi::Core::Mixin.new scheme, term, title, attributes, related, actions, location
          when 'action'
            Occi::Core::Action.new scheme, term, title, attributes
          else
            raise "Category with class #{match[:class]} not recognized in string: #{string}"
        end
      end

      def self.attribute(string)
        # create regular expression from regexp string
        regexp = Regexp.new(REGEXP_ATTRIBUTE)
        # match string to regular expression
        match = regexp.match string

        raise "could not match #{string}" unless match

        value = match[:string] if match[:string]

        if match[:number]
          match[:number].include?('.') ? value = match[:number].to_f : value = match[:number].to_i
        end

        value = match[:bool] == "true" if match[:bool]
        Occi::Core::Attributes.split match[:name] => value
      end

      def self.link_string(string, source)
        # create regular expression from regexp string
        regexp = Regexp.new(REGEXP_LINK)
        # match string to regular expression
        match = regexp.match string

        raise "could not match #{string}" unless match

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
        attributes = attributes.inject(Hashie::Mash.new) { |hsh, attribute| hsh.merge!(Occi::Parser::Text.attribute('X-OCCI-Attribute: ' + attribute)) }
        Occi::Core::Link.new kind, mixins, attributes, actions, rel, target, source, location
      end

      def self.location(string)
        # create regular expression from regexp string
        regexp = Regexp.new(REGEXP_LOCATION)
        # match string to regular expression
        match = regexp.match string

        raise "could not match #{string}" unless match

        match[:location]
      end

    end
  end
end
