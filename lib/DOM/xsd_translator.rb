module Schemr::DOM
  module XsdTranslator
    def tree_and_root(rule_tree = @rule_tree)
      tree = ElementTree.new("xs:schema")
      tree['xmlns:xs'] ="http://www.w3.org/2001/XMLSchema"
      tree['xmlns:xml'] = "http://www.w3.org/XML/1998/namespace"
      tree << Element.new("xs:import", :namespace => "http://www.w3.org/XML/1998/namespace", :schemaLocation => "http://www.w3.org/2001/xml.xsd")
      return tree, tree
    end
    
    def translate_nested_rules(rule_tree = @rule_tree)
      rule_tree.nested_rules.each do |rule|
        @root << translate_nested_rule(rule)
      end
    end
    
    def translate_nested_rule(rule)
      translate_rule(rule)
    end
    
    def translate_rule(rule)
      rule_element = Element.new("xs:element")
      rule_element.name = rule.name
      
      if rule.nested_rules.empty? && rule.attributes.empty? && rule.optional_attributes.empty?
        rule_element.type = "xs:string"
      else
        complex_element = Element.new("xs:complexType")
      
        translate_attributes(rule).each {|e| complex_element << e}
        
        unless rule.nested_rules.empty?
          sequence_element = Element.new("xs:sequence")
          rule.nested_rules.each {|r| sequence_element << translate_rule(r)}
          complex_element << sequence_element
        end
        
        rule_element << complex_element
      end
      
      rule_element
    end
    
    def translate_reference_rule(rule)
      rule_element = Element.new("xs:element")
      rule_element.ref = "tns:#{rule.name}"
      rule_element.minOccurs = rule.min.to_s
      rule_element.maxOccurs = rule.max == :many ? "unbounded" : rule.max.to_s
      rule_element
    end
    
    def translate_rule_with_reference_check(rule)
      if rule.has_reference?
        translate_reference_rule(rule)
      else
        translate_rule_without_reference_check(rule)
      end
    end
    
    alias_method_chain :translate_rule, :reference_check
    
    def translate_attributes(rule)
      attribute_elements = []
      
      rule.attributes.each do |key, value|
        attribute_elements << Element.new("xs:attribute", :name => key, :type => "xs:string", :use => "required")
      end
      
      attribute_elements
    end
  end
end