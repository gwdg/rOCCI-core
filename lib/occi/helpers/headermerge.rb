module Occi
  module Helpers
    module HeaderMerge

      # Combines two mashes. Keys unique to 'other' are copied, keys existing in both mashes are concatenated with the Separator inbetween
      # @param [Hashie::Mash] Target Mash
      # @param [Hashie::Mash] Other Mash
      # @param [String] Separator
      # @return [Hashie::Mash] Target Mash
      def self.header_merge(target, other, separator=',')
        other.each_pair do |key,val|
          if target.key?(key)
            target[key] = "#{target[key]}#{separator}#{val}"
          else
            target[key] = val
          end
        end
        target
      end
    end
  end
end
