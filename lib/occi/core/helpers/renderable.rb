module Occi
  module Core
    module Helpers
      # @author Boris Parak <parak@cesnet.cz>
      module Renderable
        # Methods expected on supported renderer classes
        REQUIRED_RENDERER_METHODS = [:renderer?, :formats, :render].freeze
        # Parent namespace of all supported renderer classes
        RENDERER_NAMESPACE = Occi::Core::Renderers

        # @param format [String]
        # @param options [Hash]
        def render(format, options = {})
          options[:format] = format
          available_renderers[format].render(self, options)
        end

        # @param base [Class]
        def self.included(base)
          available_formats.each do |format|
            base.send(:define_method, "to_#{format}", proc { render(format) })
          end
        end

        #
        # @param base [Class, Object]
        def self.extended(base)
          base.is_a?(Class) ? raise("#{self} cannot extend #{base}") : included(base.class)
        end

        # @return [Array]
        def self.available_formats
          available_renderers.keys
        end

        # @return [Hash]
        def self.available_renderers
          rcands = renderer_candidates.select { |candidate| renderer?(candidate) }

          ravail = {}
          rcands.each do |rcand|
            rcand.formats.each { |rcand_f| ravail[rcand_f] = rcand }
          end

          ravail
        end

        # @param candidate [Object]
        def self.renderer?(candidate)
          return false unless candidate.is_a?(Class)

          required_renderer_methods.each { |method| return false unless candidate.respond_to?(method) }
          candidate.renderer?
        end

        # @return [Array]
        def self.renderer_candidates
          renderer_namespace.constants.collect { |const| renderer_namespace.const_get(const) }
        end

        # @return [Array]
        def self.required_renderer_methods
          REQUIRED_RENDERER_METHODS
        end

        # @return [Module]
        def self.renderer_namespace
          RENDERER_NAMESPACE
        end
      end
    end
  end
end
