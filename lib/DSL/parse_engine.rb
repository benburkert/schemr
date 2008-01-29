module Schemr::DSL
  class ParseEngine
    include InlineInterpreter
    
    def initialize(template)
      @lines = template.split(/\n\r|\n/)
    end
    
    def parse
      return nil if @lines.empty?
      return nil unless @lines.first =~ /^!!!/
      
      arg_string = @lines.first.rightwise(/^!!!/)
      
      @doc = RuleTree.new(line_eval(arg_string))
      
      @current_line = 0
      @line_stack = [@lines.first]
      @rule_stack = [@doc]
      
      
      process_hierarchy(@doc)
      
      @doc
    end
    
    def process_hierarchy(parent)
      while more_lines?
        return unless process_next_line(parent)
      end
    end
    
    def process_next_line(parent)
      @current_line += 1
      line = @lines[@current_line]
      
      parse_next_line(line, parent) if indentation(line) > indentation(@line_stack.last)
    end
    
    def process_next_line_with_inline_code_check(parent)
      if next_is_rule?
        process_next_line_without_inline_code_check(parent)
      else
        interpret_next_line(parent)
      end
    end
    
    alias_method_chain :process_next_line, :inline_code_check
    
    def process_next_line_with_attribute_check(parent)
      if next_is_attribute?
        parse_next_attribute(parent)
      else
        process_next_line_without_attribute_check(parent)
      end
    end
    
    alias_method_chain :process_next_line, :attribute_check
    
    def process_next_line_with_nested_check(parent)
      if next_is_nested?
        process_next_line_without_nested_check(parent)
      end
    end
    
    alias_method_chain :process_next_line, :nested_check
    
    def process_next_line_with_parsable_check(parent)
      if next_is_parsable?
        process_next_line_without_parsable_check(parent)
      else
        skip_next_line
      end
    end
    
    alias_method_chain :process_next_line, :parsable_check
    
    def interpret_next_line(parent)
      @current_line += 1
      line = @lines[@current_line]
      
      line_eval(line, parent)
    end
    
    def parse_next_line(line, parent)
        @line_stack << line
        
        arguments = args_eval(line, parent)
        
        rule = Rule.new(*arguments)
        
        process_hierarchy(rule)
          
        @line_stack.pop
    end
    
    def next_attribute_is_optional?
      next_line.lstrip =~ /^\^\?/
    end
    
    def parse_next_attribute(parent)
      if next_attribute_is_optional?
        parent.optional_attributes = attr_eval(next_line).merge(parent.optional_attributes)
      else
        parent.attributes = attr_eval(next_line).merge(parent.attributes)
      end
      @current_line += 1
    end
    
    def parse_attribute_key(line)
      eval(line.lstrip.rightwise(/\^\??/).leftwise(/=>/))
    end
    
    def parse_attribute_value(line)
      eval(line.lstrip.rightwise(/=>/))
    end
    
    def skip_next_line
      @current_line += 1
    end
    
    def next_is_attribute?
      next_line.lstrip =~ /^\^/
    end
    
    def next_is_rule?
      next_line.lstrip =~ /^(<|#|!!)/
    end
    
    def next_is_parsable?
      !next_line.strip.empty? # blank line
    end
    
    def more_lines?
      @current_line < @lines.length - 1
    end
    
    def next_is_nested?
      indentation(@line_stack.last) < indentation(next_line)
    end
    
    def next_line
      @lines[@current_line + 1] || ""
    end
    
    def indentation(line)
      line.leftwise(/\S/).length
    end
  end
end