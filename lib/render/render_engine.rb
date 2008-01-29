module Schemr
  class RenderEngine
    
    RENDERER_MAP = {
      :dtd => DtdRenderer,
      :xml => XmlRenderer
    }
    
    def initialize(*args)
      args, options = args_and_options(*args)
      
      @root = args.first if args.first
      @out = ""
      @endl = "\n"
    end
    
    def render_as(renderer)
      
      
      self.extend(RENDERER_MAP[renderer]) if RENDERER_MAP.has_key? renderer
      
      render(@root, @out)
      @out
    end
  end
end