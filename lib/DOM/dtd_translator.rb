module Schemr::DOM
  module DtdTranslator
    
    #element attribute names
    ELEMENT_NAME = "element-name"
    ELEMENT_CATEGORY = "category"
    ELEMENT_CONTENT = "element-content"
    
    #attlist attribute names
    ATTRIBUTE_NAME = "attribute-name"
    ATTRIBUTE_TYPE = "attribute-type"
    DEFAULT_VALUE = "default-value"
    
    #element category constants
    ANY = "ANY"
    EMPTY = "EMPTY"
    PCDATA = "#PCDATA"
    
    #attlist default-value constants
    REQUIRED = "#REQUIRED"
    FIXED = "#FIXED"
    IMPLIED = "#IMPLIED"
    
    CDATA = "CDATA"
    
    def tree_and_root(rule_tree = @rule_tree)
      tree = ElementTree.new("DOCTYPE")
      tree["root-element"] = rule_tree.name
      return tree, tree
    end
    
    def attlist_default_value(options)
      "\"#{options[:value]}\""
    end
    
    
    def attlist_default_value_with_optional_check(options)
      unless options[:optional] 
        "#{FIXED} #{attlist_default_value_without_optional_check(options)}"
      else
        attlist_default_value_without_optional_check(options)
      end
    end
    
    alias_method_chain :attlist_default_value, :optional_check
    
    def attlist_default_value_with_array_check(options)
      if options[:value].is_a? Array
        "(#{options[:value].join('|')}) #{REQUIRED}"
      else
        attlist_default_value_without_array_check(options)
      end
    end
    
    alias_method_chain :attlist_default_value, :array_check
    
    def attlist_default_value_with_value_check(options)
      unless options[:value]
        options[:optional] ? IMPLIED : REQUIRED
      else
        attlist_default_value_without_value_check(options)
      end
    end
    
    alias_method_chain :attlist_default_value, :value_check
    
    def attlist_attribute_type(options)
      case options[:value]
      when String, nil
        CDATA
      end
    end
    
    def attlist_attribute_type_
      
    end
    
    def attlist_attributes(options = {})
      {
        ELEMENT_NAME => options[:rule_name],
        ATTRIBUTE_NAME => options[:attr_name],
        ATTRIBUTE_TYPE => attlist_attribute_type(options),
        DEFAULT_VALUE => attlist_default_value(options)
      }
    end
    
    def translate_attributes(rule)
      attribute_elements = []
      
      rule.attributes.each do |key, value|
        attribute_elements << Element.new("ATTLIST",
          attlist_attributes(:rule_name => rule.name, :attr_name => key, :value =>value))
      end
      
      rule.optional_attributes.each do |key, value|
        attribute_elements << Element.new("ATTLIST",
          attlist_attributes(:rule_name => rule.name, :attr_name => key, :value =>value, :optional => true))
      end
      
      attribute_elements
    end
    
    def translate_nested_rules(rule_tree = @rule_tree)
      rule_tree.nested_rules.each do |rule|
        translate_nested_rule(rule)
      end
    end
    
    def translate_nested_rule(rule)
      @root << translate_rule(rule)
      translate_attributes(rule).each {|element| @root << element }
      translate_nested_rules(rule)
    end
    
    def translate_nested_rule_with_repetative_element_check(rule)
      if element = @root.children.find {|child| child['element-name'] == rule.name && child.identifier == "ELEMENT"}
        translate_repetative_element(rule, element)
      else
        translate_nested_rule_without_repetative_element_check(rule)
      end
    end
    
    alias_method_chain :translate_nested_rule, :repetative_element_check
    
    def translate_repetative_element(rule, element)
      unless element['element-content'] == element_content(rule) || element['element-content'].empty?
        element['element-content'] = "#{element['element-content']}|#{element_content(rule)}"
      end
    end
    
    def translate_repetative_element_with_element_content_check(rule, element)
      if element_content(rule)
        translate_repetative_element_without_element_content_check(rule, element)
      end
    end
    
    alias_method_chain :translate_repetative_element, :element_content_check
    
    def element_content(rule)
      unless rule.nested_rules.empty?
        rule_map = map_rules_to_occurrences(rule.nested_rules)
        "(" + rule_map.collect{|name, symbol| "#{name}#{symbol}"}.join(',') + ")"
      end
    end
    
    def map_rules_to_occurrences(rules)
      map = {}
      rules.each do |rule|
        map[rule.name] = occurrence_symbol(rule) unless map.has_key? rule.name
      end
      map
    end
    
    def occurrence_symbol(rule)
      case [rule.min, rule.max]
      when [1, 1]
        ""
      when [0, :many]
        "*"
      when [1, :many]
        "+"
      when [0, 1]
        "?"
      end
    end
    
    def element_category_for_value(value)
      case value
      when Array
        ANY
      when String, nil
        "(#{PCDATA})"
      end
    end
    
    def element_category(rule)
      EMPTY
    end
    
    def element_category_with_attributes_check(rule)
      if rule.attributes.empty? && rule.optional_attributes.empty?
        "(#{PCDATA})"
      else
        element_category_without_attributes_check(rule)
      end
    end
    
    alias_method_chain :element_category, :attributes_check
    
    def element_category_with_value_check(rule)
      unless rule.value.nil?
        element_category_for_value(rule.value)
      else
        element_category_without_value_check(rule)
      end
    end
    
    alias_method_chain :element_category, :value_check
    
    def element_category_with_nested_check(rule)
      if rule.nested_rules.empty?
        element_category_without_nested_check(rule)
      end
    end
    
    alias_method_chain :element_category, :nested_check
    
    def element_attributes(rule)
      {
        ELEMENT_NAME => rule.name,
        ELEMENT_CONTENT => element_content(rule),
        ELEMENT_CATEGORY => element_category(rule)
      }
    end
    
    def translate_rule(rule)
      Element.new("ELEMENT", element_attributes(rule))
    end
  end
end