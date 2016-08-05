module DotStarLib
  class Value
    attr_accessor :red, :green, :blue
    def initialize(r, g, b)
      @red = r
      @green = g
      @blue = b
    end
    def ==(o)
      o.class == self.class && o.state == state
    end
    def state
      return [@red, @green, @blue]
    end
  end

  class Channel
    attr_accessor :values
    def initialize(values)
      @values = values
    end
    def size
      return @values.size
    end
    def ==(o)
      o.class == self.class && o.state == state
    end
    def state
      return @values
    end
    
  end

  class Filter
    @@filters = {}
    def self.register(name, params)
      @@filters[name] = {clazz: self, params: params}
    end
    def self.filters
      @@filters
    end
    def process(channel)
      raise 'process(channels) not implemented'
    end
    def set(params)
      raise 'set(params) not implemented'
    end
  end
end

