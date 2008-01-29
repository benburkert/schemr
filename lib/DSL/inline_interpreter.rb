module Schemr::DSL
  module InlineInterpreter
    
    ONE_INLINE_RULE               = "<"
    ONE_TO_MANY_INLINE_RULE       = "<+"
    ZERO_TO_MANY_INLINE_RULE      = "<*"
    ZERO_TO_ONE_INLINE_RULE       = "<?"
    
    DECLARATIVE_RULE_SYMBOL       = "!!"
    
    ONE_REFERENCED_RULE           = "#"
    ONE_TO_MANY_REFERENCED_RULE   = "#\+"
    ZERO_TO_MANY_REFERENCED_RULE  = "#\*"
    ZERO_TO_ONE_REFERENCED_RULE   = "#\?"
    
    REQUIRED_ATTRIBUTE            = "^"
    OPTIONAL_ATTRIBUTE            = "^?"
    
    ATTRIBUTE_SYMBOLS = [
      OPTIONAL_ATTRIBUTE,
      REQUIRED_ATTRIBUTE
    ]
    
    MULTIPLICITY_MAP = {
      ONE_REFERENCED_RULE => :one,
      ONE_TO_MANY_INLINE_RULE => :one_to_many,
      ZERO_TO_MANY_INLINE_RULE => :zero_to_many,
      ZERO_TO_ONE_INLINE_RULE => :zero_to_one,
      ONE_INLINE_RULE => :one,
      ONE_TO_MANY_REFERENCED_RULE => :one_to_many,
      ZERO_TO_MANY_REFERENCED_RULE => :zero_to_many,
      ZERO_TO_ONE_REFERENCED_RULE => :zero_to_one
    }
    
    def line_eval(line, object = Object.new)
      object.instance_eval(line)
    end
    
    def args_eval(line)
      tokens = []
      while(data = line.match(/\[.*\]/))
        data.pre_match.split(',').each {|s| tokens << s}
        tokens << tokens.pop + data[0]
        line = data.post_match
      end
      
      line.split(',').each {|s| tokens << s}
      hash_tokens = []
      
      tokens.reverse.each do |token|
        break unless token =~ /=>/
        
        hash_tokens << tokens.pop
      end
      
      if tokens.empty?
        tokens = hash_tokens.pop.split(/=>/)
      end
      
      line_eval("[#{tokens.join(',')}#{', ' unless tokens.empty? || hash_tokens.empty?}#{hash_tokens.empty? ? '' : "{#{hash_tokens.reverse.join(',')}}"}]")
    end
    
    def args_eval_with_multiplicity_symbol(line)
      if symbol = multiplicity_symbol(line.lstrip)
        add_options_unless_present(args_eval_without_multiplicity_symbol(line.rightwise(symbol)), { :multiplicity => MULTIPLICITY_MAP[symbol]})
      else
        args_eval_without_multiplicity_symbol(line) 
      end
    end
    
    alias_method_chain :args_eval, :multiplicity_symbol
    
    def args_eval_with_base_rule_symbol(line)
      unless (symbol = base_rule_symbol(line)).empty?
        add_options_unless_present(args_eval_without_base_rule_symbol(line.reverse.rightwise(/<</).reverse), {:base_rule => eval(symbol)})
      else
        args_eval_without_base_rule_symbol(line)
      end
    end
    
    alias_method_chain :args_eval, :base_rule_symbol
    
    def args_eval_with_declaration_rule_symbol(line)
      if begins_with_declaration_symbol?(line)
        add_options_unless_present(args_eval_without_declaration_rule_symbol(line.rightwise(Regexp.escape(DECLARATIVE_RULE_SYMBOL))), {:inline => false})
      else
        args_eval_without_declaration_rule_symbol(line)
      end
    end
    
    alias_method_chain :args_eval, :declaration_rule_symbol
    
    def args_eval_with_reference_rule_symbol(line)
      if begins_with_reference_symbol?(line)
        add_options_unless_present(args_eval_without_reference_rule_symbol(line), {:reference_rule => true})
      else
        args_eval_without_reference_rule_symbol(line)
      end
    end
    
    alias_method_chain :args_eval, :reference_rule_symbol
    
    def args_eval_with_parent_argument(line, parent = nil)
      if parent.nil?
        args_eval_without_parent_argument(line)
      else
        add_options_unless_present(args_eval_without_parent_argument(line), {:parent => parent})
      end
    end
    
    alias_method_chain :args_eval, :parent_argument
    
    def args_eval_with_attribute_symbol(line, parent = nil)
      if starts_with_attribute_symbol?(line.lstrip)
        line = line.lstrip.rightwise(/\^\??/)
        args_eval_without_attribute_symbol(line, parent)
      else
        args_eval_without_attribute_symbol(line, parent)
      end
    end
    
    alias_method_chain :args_eval, :attribute_symbol
    
    def base_rule_symbol(line)
      line.reverse.leftwise(/<</).reverse.strip
    end
    
    def multiplicity_symbol(line)
      MULTIPLICITY_MAP.keys.sort{|a, b| b.length <=> a.length}.find do |symbol|
        line =~ /^#{Regexp.escape(symbol)}/
      end
    end
    
    def starts_with_attribute_symbol?(line)
      line =~ /^\^/
    end
    
    def begins_with_reference_symbol?(line)
      line.lstrip =~ /\#/
    end
    
    def begins_with_declaration_symbol?(line)
      line.lstrip =~ /^#{Regexp.escape(DECLARATIVE_RULE_SYMBOL)}/
    end
    
    def attr_eval(line)
      { args_eval(line).first => args_eval(line).second }
    end
  end
end