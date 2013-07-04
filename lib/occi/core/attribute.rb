module Occi
  module Core
    module Attribute

      attr_accessor :properties

    end
  end
end

class StringAttribute < String

  attr_accessor :properties

  def properties
    self.properties ||= Occi::Core::Properties.new
  end

end

class NumericAttribute

  attr_accessor :properties

  def properties
    self.properties ||= Occi::Core::Properties.new :type => 'number'
  end

end

class FalseClass

  include Occi::Core::Attribute

  def properties
    self.properties ||= Occi::Core::Properties.new :type => 'boolean'
  end

end

class TrueClass

  include Occi::Core::Attribute

  def properties
    self.properties ||= Occi::Core::Properties.new :type => 'boolean'
  end

end

#module Occi
#  module Core
#    class Attribute < Occi::Core::AttributeProperties
#
#      attr_accessor :_value
#
#      # @param [Hash] properties
#      # @param [Hash] default
#      def initialize(properties={})
#        super(properties)
#        case properties
#          when Occi::Core::AttributeProperties
#            self._value = properties._value if properties._value if properties.respond_to?('_value')
#          else
#            self._value = properties[:value] if properties[:value]
#        end
#      end
#
#      def _value=(value)
#        raise "value #{value} can not be assigned as the attribute is not mutable" unless self._mutable if self._value
#        case self._type
#          when 'number'
#            raise "value #{value} from class #{value.class.name} does not match attribute property type #{self._type}" unless value.kind_of?(Numeric)
#          when 'boolean'
#            raise "value #{value} from class #{value.class.name} does not match attribute property type #{self._type}" unless !!value == value
#          when 'string'
#            raise "value #{value} from class #{value.class.name} does not match attribute property type #{self._type}" unless value.kind_of?(String) || value.kind_of?(Occi::Core::Entity)
#          else
#            raise "property type #{self._type} is not one of the allowed types number, boolean or string"
#        end
#        raise "value #{value} does not match pattern #{self._pattern}" if value.to_s.scan(Regexp.new(self._pattern)).empty? unless value.kind_of?(Occi::Core::Entity)
#        @_value = value
#      end
#
#      def inspect
#        self._value
#      end
#
#      def to_s
#        self._value
#      end
#
#      def empty?
#        self._value.nil?
#      end
#
#    end
#  end
#end
