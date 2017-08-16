module Occi
  module Infrastructure
    # Dummy sub-class of `Occi::Core::Resource` meant to simplify handling
    # of known instances of the given sub-class. Does not contain any functionality.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Compute < Occi::Core::Resource
      # @return [Enumerable] filtered set of links
      def storagelinks
        links_by_kind_identifier Occi::Infrastructure::Constants::STORAGELINK_KIND
      end

      # @return [Enumerable] filtered set of links
      def networkinterfaces
        links_by_kind_identifier Occi::Infrastructure::Constants::NETWORKINTERFACE_KIND
      end

      # @return [Occi::Core::Mixin, NilClass] filtered mixin
      def os_tpl
        select_mixin Occi::Infrastructure::Mixins::OsTpl.new
      end

      # @return [Occi::Core::Mixin, NilClass] filtered mixin
      def resource_tpl
        select_mixin Occi::Infrastructure::Mixins::ResourceTpl.new
      end
    end
  end
end
