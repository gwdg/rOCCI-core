module Occi
  module Core
    # Implements a generic envelope for all OCCI-related instances. This
    # class can be used directly for various reasons or, in a specific way,
    # as an ancestor for custom classes providing `Model`-like functionality.
    # Its primary purpose is to provide a tool for working with multiple
    # sets of different instance types, aid with their transport and validation.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Model < Collection
      # Triggers validation on the underlying `Collection` instance. In addition,
      # validates all included entities and action instances against categories
      # defined in the model. Only the existence of categories is checked, no
      # further checks are performed.
      #
      # See `#valid!` on `Collection` for details.
      def valid!
        super
        valid_entities!
        valid_action_instances!
      end

      # Quietly validates the model. This method does not raise exceptions with
      # detailed descriptions of detected problems.
      #
      # See `#valid!` for details.
      def valid?
        super && valid_helper?(:valid_entities!) && valid_helper?(:valid_action_instances!)
      end

      private

      # :nodoc:
      def valid_helper?(method)
        begin
          send method
        rescue Occi::Core::Errors::InstanceValidationError => ex
          logger.warn "Entity invalid: #{ex.message}"
          return false
        end

        true
      end

      # :nodoc:
      def valid_entities!
        cached_kinds = kinds
        cached_mixins = mixins
        entities.each do |ent|
          raise Occi::Core::Errors::InstanceValidationError,
                "Entity ID[#{ent.id}] contains undeclared " \
                "kind #{ent.kind_identifier}" unless cached_kinds.include?(ent.kind)
          valid_mixins!(ent, cached_mixins)
        end
      end

      # :nodoc:
      def valid_mixins!(ent, cached_mixins)
        ent.mixins.each do |mxn|
          raise Occi::Core::Errors::InstanceValidationError,
                "Entity ID[#{ent.id}] contains undeclared " \
                "mixin #{mxn.identifier}" unless cached_mixins.include?(mxn)
        end
      end

      # :nodoc:
      def valid_action_instances!
        cached_actions = actions
        action_instances.each do |ai|
          raise Occi::Core::Errors::InstanceValidationError,
                'Action instance contains undeclared ' \
                "action #{ai.action_identifier}" unless cached_actions.include?(ai.action)
        end
      end
    end
  end
end
