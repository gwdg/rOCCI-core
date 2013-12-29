module Occi
  module Parser
    module Text
      module Constants

        # Regular expressions
        REGEXP_QUOTED_STRING = /([^"\\]|\\.)*/
        REGEXP_LOALPHA = /[a-z]/
        REGEXP_ALPHA = /[a-zA-Z]/
        REGEXP_DIGIT = /[0-9]/
        REGEXP_INT = /#{REGEXP_DIGIT}+/
        REGEXP_FLOAT = /#{REGEXP_INT}\.#{REGEXP_INT}/
        REGEXP_NUMBER = /#{REGEXP_FLOAT}|#{REGEXP_INT}/
        REGEXP_BOOL = /\b(?<!\|)true(?!\|)\b|\b(?<!\|)false(?!\|)\b/

        # Regular expressions for OCCI
        REGEXP_TERM = /(#{REGEXP_ALPHA}|#{REGEXP_DIGIT})(#{REGEXP_ALPHA}|#{REGEXP_DIGIT}|-|_)*/# Compatibility with terms starting with a number
        REGEXP_TERM_STRICT = /#{REGEXP_LOALPHA}(#{REGEXP_LOALPHA}|#{REGEXP_DIGIT}|-|_)*/
        REGEXP_SCHEME = /#{URI::ABS_URI_REF}#/
        REGEXP_TYPE_IDENTIFIER = /#{REGEXP_SCHEME}#{REGEXP_TERM}/
        REGEXP_TYPE_IDENTIFIER_STRICT = /#{REGEXP_SCHEME}#{REGEXP_TERM_STRICT}/
        REGEXP_CLASS = /\b(?<!\|)action(?!\|)\b|\b(?<!\|)mixin(?!\|)\b|\b(?<!\|)kind(?!\|)\b/
        REGEXP_TYPE_IDENTIFIER_LIST = /#{REGEXP_TYPE_IDENTIFIER}(\s+#{REGEXP_TYPE_IDENTIFIER})*/
        REGEXP_TYPE_IDENTIFIER_LIST_STRICT = /#{REGEXP_TYPE_IDENTIFIER_STRICT}(\s+#{REGEXP_TYPE_IDENTIFIER_STRICT})*/

        REGEXP_ATTR_COMPONENT = /#{REGEXP_LOALPHA}(#{REGEXP_LOALPHA}|#{REGEXP_DIGIT}|-|_)*/
        REGEXP_ATTRIBUTE_NAME = /#{REGEXP_ATTR_COMPONENT}(\.#{REGEXP_ATTR_COMPONENT})*/
        REGEXP_ATTRIBUTE_PROPERTY = /\b(?<!\|)immutable(?!\|)\b|\b(?<!\|)required(?!\|)\b/
        REGEXP_ATTRIBUTE_DEF = /(#{REGEXP_ATTRIBUTE_NAME})(\{#{REGEXP_ATTRIBUTE_PROPERTY}(\s+#{REGEXP_ATTRIBUTE_PROPERTY})*\})?/
        REGEXP_ATTRIBUTE_LIST = /#{REGEXP_ATTRIBUTE_DEF}(\s+#{REGEXP_ATTRIBUTE_DEF})*/
        REGEXP_ATTRIBUTE_REPR = /#{REGEXP_ATTRIBUTE_NAME}=("#{REGEXP_QUOTED_STRING}"|#{REGEXP_NUMBER}|#{REGEXP_BOOL})/

        REGEXP_ACTION = /#{REGEXP_TYPE_IDENTIFIER}/
        REGEXP_ACTION_STRICT = /#{REGEXP_TYPE_IDENTIFIER_STRICT}/
        REGEXP_ACTION_LIST = /#{REGEXP_ACTION}(\s+#{REGEXP_ACTION})*/
        REGEXP_ACTION_LIST_STRICT = /#{REGEXP_ACTION_STRICT}(\s+#{REGEXP_ACTION_STRICT})*/

        REGEXP_RESOURCE_TYPE = /#{REGEXP_TYPE_IDENTIFIER}(\s+#{REGEXP_TYPE_IDENTIFIER})*/
        REGEXP_RESOURCE_TYPE_STRICT = /#{REGEXP_TYPE_IDENTIFIER_STRICT}(\s+#{REGEXP_TYPE_IDENTIFIER_STRICT})*/
        REGEXP_LINK_INSTANCE = /#{URI::URI_REF}/
        REGEXP_LINK_TYPE = /#{REGEXP_TYPE_IDENTIFIER}(\s+#{REGEXP_TYPE_IDENTIFIER})*/
        REGEXP_LINK_TYPE_STRICT = /#{REGEXP_TYPE_IDENTIFIER_STRICT}(\s+#{REGEXP_TYPE_IDENTIFIER_STRICT})*/

        # Regular expression for OCCI Categories
        REGEXP_CATEGORY = "Category:\\s*(?<term>#{REGEXP_TERM})" << # term (mandatory)
            ";\\s*scheme=\"(?<scheme>#{REGEXP_SCHEME})#{REGEXP_TERM}?\"" << # scheme (mandatory)
            ";\\s*class=\"?(?<class>#{REGEXP_CLASS})\"?" << # class (mandatory)
            "(;\\s*title=\"(?<title>#{REGEXP_QUOTED_STRING})\")?" << # title (optional)
            "(;\\s*rel=\"(?<rel>#{REGEXP_TYPE_IDENTIFIER_LIST})\")?"<< # rel (optional)
            "(;\\s*location=\"(?<location>#{URI::URI_REF})\")?" << # location (optional)
            "(;\\s*attributes=\"(?<attributes>#{REGEXP_ATTRIBUTE_LIST})\")?" << # attributes (optional)
            "(;\\s*actions=\"(?<actions>#{REGEXP_ACTION_LIST})\")?" << # actions (optional)
            ';?' # additional semicolon at the end (not specified, for interoperability)
        REGEXP_CATEGORY_STRICT = "Category:\\s*(?<term>#{REGEXP_TERM_STRICT})" << # term (mandatory)
            ";\\s*scheme=\"(?<scheme>#{REGEXP_SCHEME})\"" << # scheme (mandatory)
            ";\\s*class=\"(?<class>#{REGEXP_CLASS})\"" << # class (mandatory)
            "(;\\s*title=\"(?<title>#{REGEXP_QUOTED_STRING})\")?" << # title (optional)
            "(;\\s*rel=\"(?<rel>#{REGEXP_TYPE_IDENTIFIER_LIST_STRICT})\")?"<< # rel (optional)
            "(;\\s*location=\"(?<location>#{URI::URI_REF})\")?" << # location (optional)
            "(;\\s*attributes=\"(?<attributes>#{REGEXP_ATTRIBUTE_LIST})\")?" << # attributes (optional)
            "(;\\s*actions=\"(?<actions>#{REGEXP_ACTION_LIST_STRICT})\")?" << # actions (optional)
            ';?' # additional semicolon at the end (not specified, for interoperability)

        # Regular expression for OCCI Link Instance References
        REGEXP_LINK = "Link:\\s*\\<(?<uri>#{URI::URI_REF})\\>" << # uri (mandatory)
            ";\\s*rel=\"(?<rel>#{REGEXP_RESOURCE_TYPE})\"" << # rel (mandatory)
            "(;\\s*self=\"(?<self>#{REGEXP_LINK_INSTANCE})\")?" << # self (optional)
            "(;\\s*category=\"(?<category>(;?\\s*(#{REGEXP_LINK_TYPE}))+)\")?" << # category (optional)
            "(?<attributes>(;?\\s*(#{REGEXP_ATTRIBUTE_REPR}))*)" << # attributes (optional)
            ';?' # additional semicolon at the end (not specified, for interoperability)
        REGEXP_LINK_STRICT = "Link:\\s*\\<(?<uri>#{URI::URI_REF})\\>" << # uri (mandatory)
            ";\\s*rel=\"(?<rel>#{REGEXP_RESOURCE_TYPE_STRICT})\"" << # rel (mandatory)
            "(;\\s*self=\"(?<self>#{REGEXP_LINK_INSTANCE})\")?" << # self (optional)
            "(;\\s*category=\"(?<category>(;?\\s*(#{REGEXP_LINK_TYPE_STRICT}))+)\")?" << # category (optional)
            "(?<attributes>(;\\s*(#{REGEXP_ATTRIBUTE_REPR}))*)" << # attributes (optional)
            ';?' # additional semicolon at the end (not specified, for interoperability)

        # Regular expression for OCCI Entity Attributes
        REGEXP_ATTRIBUTE = "X-OCCI-Attribute:\\s*(?<name>#{REGEXP_ATTRIBUTE_NAME})=(\"(?<string>#{REGEXP_QUOTED_STRING})\"|(?<number>#{REGEXP_NUMBER})|(?<bool>#{REGEXP_BOOL}))" <<
            ';?' # additional semicolon at the end (not specified, for interoperability)

        # Regular expression for OCCI Location
        REGEXP_LOCATION = "X-OCCI-Location:\\s*(?<location>#{URI::URI_REF})" <<
            ';?' # additional semicolon at the end (not specified, for interoperability)

      end
    end
  end
end