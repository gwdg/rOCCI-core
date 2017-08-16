module Occi
  module Infrastructure
    class Compute
      # @return [Enumerable] filtered set of links
      def securitygrouplinks
        links_by_kind_identifier Occi::InfrastructureExt::Constants::SECURITY_GROUP_LINK_KIND
      end
    end
  end
end
