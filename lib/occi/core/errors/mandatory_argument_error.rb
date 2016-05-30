# Custom error class indicating issues with mandatory arguments and
# their format/content.
#
# @author Boris Parak <parak@cesnet.cz>
class Occi::Core::Errors::MandatoryArgumentError < ArgumentError; end
