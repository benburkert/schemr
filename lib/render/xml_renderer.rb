module Schemr
  module XmlRenderer
    
    def render(element_tree, out)
      raise "Output destination does not respond to <" unless out.respond_to? :<<
      
      @out ||= out
      @tab ||= "  "
      @tab_count ||= 0
      
      render_element(element_tree)
    end
  
    def render_element(element)
      @out << tabs << "<#{element.identifier}"
      unless element.attributes.empty?
        element.attributes.each do |key, value|
          escaped_value = value.gsub('"', "'")
          @out << " #{key}=\"#{escaped_value}\""
        end
      end
      
      if element.children.empty?
        @out << "/>" << @endl
      else
        @out << ">" << @endl
        
        @tab_count += 1
        
        element.children.each do |child|
          render_element(child)
        end
        
        @tab_count -= 1
        
        @out << tabs << "</#{element.identifier}>" << @endl
      end
    end
    
    def tabs
      @tab * @tab_count
    end
  end
end