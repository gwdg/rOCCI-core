# :nodoc:
class Hash
  include Yell::Loggable
  include Occi::Core::Helpers::HashDereferencer
end
