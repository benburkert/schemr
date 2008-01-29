module Schemr::DOM
  class Element
    attr_accessor :identifier, :attributes, :children
    
    def initialize(*args)
      args, options = args_and_options(*args)
      @identifier = args.first
      
      @attributes = {}
      options.each {|key, value| @attributes.store(key.to_s, value.to_s)}
      
      @children ||= []
    end
    
    def <<(element)
      @children << element
    end
    
    def method_missing_with_attribute_get(methodname, *args)
      if @attributes.has_key? methodname.id2name
        @attributes[methodname.id2name]
      else
        method_missing_without_attribute_get(methodname, *args)
      end
    end
     
    alias_method_chain :method_missing, :attribute_get
    
    def method_missing_with_attribute_set(methodname, *args)
      if methodname.to_s =~ /=$/
        @attributes.merge!(methodname.id2name.chop => args.first.to_s)
      else
        method_missing_without_attribute_set(methodname, *args)
      end
    end
    
    alias_method_chain :method_missing, :attribute_set
    
    def attribute_set(key, value = nil)
      @attributes.merge! key.to_s => value.nil? ? nil : value.to_s
      value
    end
    
    def attribute_get(key)
      if @attributes.has_key? key.to_s
        @attributes[key.to_s]
      else
        attribute_set(key)
      end
    end
    
    alias_method :[]=, :attribute_set
    alias_method :[],  :attribute_get
  end
end