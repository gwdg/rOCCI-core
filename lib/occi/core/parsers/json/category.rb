module Occi
  module Core
    module Parsers
      module Json
        # Static parsing class responsible for extracting categories from JSON.
        # Class supports 'application/json' via `json`. No other formats are supported.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Category
          include Yell::Loggable

          class << self
            # Parses categories into instances of subtypes of `Occi::Core::Category`. Internal references
            # between objects are converted from strings to actual objects. Categories provided in the model
            # will be reused but have to be declared in the parsed model as well.
            #
            # @param body [Array] JSON body for parsing
            # @param model [Occi::Core::Model] model with existing categories
            # @return [Occi::Core::Model] model with all known category instances
            def json(body, model)
              begin
                JSON.parse body, symbolize_names: true
                # convert attribute definitions
                # create instances from hashes
                # add them to model
                # run deref. on kinds (parent, actions) and mixins (applies, depends, actions)
              rescue => ex
                raise Occi::Core::Errors::ParsingError, "#{self} -> #{ex.message}", ex
              end
              model
            end
          end
        end
      end
    end
  end
end
