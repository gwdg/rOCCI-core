##
# Monkeypatch for Hashie
module Hashie
  class Hash

    # Converts a mash back to a hash (with stringified keys)
    def to_hash(options={})
      out = {}
      keys.each do |k|
        if self[k].is_a?(Array)
          k = options[:symbolize_keys] ? k.to_sym : k.to_s
          out[k] ||= []
          self[k].each do |array_object|
            out[k] << (array_object.respond_to?(:to_hash) ? array_object.to_hash : array_object)
          end
        else
          k = options[:symbolize_keys] ? k.to_sym : k.to_s
          out[k] = self[k].respond_to?(:to_hash) ? self[k].to_hash : self[k]
        end
      end
      out
    end

  end
end