class Module
  def alias_method_chain(target, feature)
    # Strip out punctuation on predicates or bang methods since
    # e.g. target?_without_feature is not a valid method name.
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
    yield(aliased_target, punctuation) if block_given?
    
    with_method, without_method = "#{aliased_target}_with_#{feature}#{punctuation}", "#{aliased_target}_without_#{feature}#{punctuation}"
    
    alias_method without_method, target
    alias_method target, with_method
    
    case
      when public_method_defined?(without_method)
        public target
      when protected_method_defined?(without_method)
        protected target
      when private_method_defined?(without_method)
        private target
    end
  end
end

class Object
  def args_and_options(*args)
    options = Hash === args.last ? args.pop : {}
    return args, options
  end
  
  def add_options_unless_present(args, options)
    args, old_options = args_and_options(*args)
    args << options.merge(old_options)
  end
end

class Array
  def second; self[1]; end
end

class String
  def rightwise(seperator)
    split(seperator).second || ""
  end
  
  def leftwise(seperator)
    parts = split(seperator)
    if parts.length < 2
      ""
    else
      parts.first
    end
  end
end