module Schemr
  module DtdRenderer
    def render(element_tree, out)
      @endl ||= "\n"
      
      raise "The root element must be DOCTYPE" unless element_tree.identifier == "DOCTYPE"
      raise "DOCTYPE does not have a name" if element_tree.attributes.empty?
      raise "Output destination does not respond to <" unless out.respond_to? :<<
      
      @out = out
      
      #@out << "<!DOCTYPE #{element_tree.children.first['element-name']} [" << @endl
      
      element_tree.children.find_all{|e| e.identifier == "ELEMENT"}.each{|e| render_ELEMENT(e)}
      
      @out << @endl
      
      element_tree.children.find_all{|e| e.identifier == "ATTLIST"}.each{|e| render_ATTLIST(e)}
      
      #@out << @endl << "]>"
    end
    
    def render_ELEMENT(element)
      @out << "<!ELEMENT #{element['element-name']} #{element.category}>" << @endl
    end
    
    def render_ELEMENT_with_content_check(element)
      if element.attributes.has_key?("element-content") && !element["element-content"].empty?
        @out << "<!ELEMENT #{element['element-name']} #{element["element-content"]}>" << @endl
      else
        render_ELEMENT_without_content_check(element)
      end
    end
    
    alias_method_chain :render_ELEMENT, :content_check
    
    def render_ATTLIST(attribute)
      @out << "<!ATTLIST #{attribute['element-name']} #{attribute['attribute-name']} #{attribute['attribute-type']} #{attribute['default-value']}>" << @endl
    end
  end
end