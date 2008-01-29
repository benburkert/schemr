module Schemr::DOM
  class TranslationEngine
    
    TRANSLATOR_MAP = {
      :dtd => DtdTranslator,
      :xsd => XsdTranslator
    }
    
    def initialize(*args)
      args, options = args_and_options(*args)
      
      self.extend(TRANSLATOR_MAP[args.first]) if TRANSLATOR_MAP.has_key? args.first
      
    end
    
    def translate(rule_tree)
      @tree, @root = tree_and_root(rule_tree)
      
      translate_nested_rules(rule_tree)
      @tree
    end
  end
end