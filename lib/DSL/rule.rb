module Schemr::DSL
  class Rule
    attr_accessor :name, :nested_rules, :attributes, :optional_attributes, :min,
                  :max, :inline, :base_rule, :parent, :reference_rule, :value
    
    def initialize(*args)
      args, options = args_and_options(*args)
      
      @name, @value = args.first.to_s, args.second if args.length > 1
      
      options = { :multiplicity => :one }.merge(options)
      
      @name = args.first.to_s if args.first
      
      extract_options(options)
      
      @optional_attributes = {}
      @nested_rules = []
      
      throw "A name is required for a rule" unless @name
      @parent << self if @parent.respond_to? :<<
    end
    
    def extract_options(options)
      @name ||= options.delete(:name).to_s
      @value ||= options.delete(:value)
      
      self.multiplicity = options.delete(:multiplicity) if options.has_key?(:multiplicity)
      @min = options.has_key?(:min) ? options.delete(:min) : @min
      @max = options.has_key?(:max) ? options.delete(:max) : @max
      @inline = options.has_key?(:inline) ? options.delete(:inline) : true
      @parent = options.delete(:parent)
      self.base_rule = options.delete(:base_rule) if options.has_key?(:base_rule)
      self.reference_rule = options.delete(:reference_rule) if options.has_key?(:reference_rule)
      @attributes = options
    end
    
    def <<(node)
      node.parent = self if node.instance_of? Schemr::DSL::Rule
      @nested_rules << node
      "rule \"#{node.name}\" is in rule \"#{name}\"'s rule chain" if rule_chain.include?(node)
    end
    
    def access_nested_rule(key)
      case key
      when String, Symbol
        @nested_rules.find {|x| x.name == key.to_s}
      else
        @nested_rules[key]
      end
    end
    
    alias_method :[], :access_nested_rule
    
    def method_missing_with_base_rule_call(methodname, *args)
      if @base_rule
        @base_rule.send(methodname, *args)
      else
        method_missing_without_base_rule_call(methodname, *args)
      end
    end
    
    alias_method_chain :method_missing, :base_rule_call
    
    def method_missing_with_attribute_call(methodname, *args)
      @attributes[methodname] || @optional_attributes[methodname] || method_missing_without_attribute_call(methodname, *args)
    end
     
    alias_method_chain :method_missing, :attribute_call
    
    def inline?
      @inline
    end
    
    def abstract?
      not inline?
    end
    
    def instance?
      inline? && has_reference?
    end
    
    def has_reference?
      @reference_rule
    end
    
    def multiplicity=(value)
      case value
      when :one
        @min = @max = 1
      when :one_to_many
        @min, @max = 1, :many
      when :zero_to_many
        @min, @max = 0, :many
      when :zero_to_one
        @min, @max = 0, 1
      when Range
        @min, @max = value.first, value.collect.last
      else
        @min = @max = 1
      end
    end
    
    def possible_base_rules
      matches = nested_rules
      chained_matches = @parent.respond_to?(:possible_base_rules) ? @parent.possible_base_rules : []
      matches.concat(chained_matches)
    end
  
    def base_rule=(value)
      case value
      when String, Symbol
        @base_rule = @parent.possible_base_rules.find{|rule| rule.name == value.to_s && rule != self}
        throw "rule \"#{value}\" was not found in the rule chain" if @base_rule.nil?
      else
        @base_rule = value
      end
    end
    
    def reference_rule=(value)
      case value
      when String, Symbol
        @reference_rule = @parent.possible_base_rules.find{|rule| rule.name == value.to_s && rule != self}
        throw "rule \"#{value}\" was not found in the rule chain" if @reference_rule.nil?
      else
        @reference_rule = value
      end
    end
    
    def rule_chain(&block)
      arr = (block.nil? || block.call(self)) ? [self] : []
      
      arr = arr + @parent.rule_chain(&block) unless @parent.nil?
      arr
    end
  end
end