module DotStarLib
  class Value
    attr_accessor :red, :green, :blue
    def initialize(r, g=0, b=0)
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
    def add(v)
      return Value.new(@red + v.red, @green + v.green, @blue + v.blue)
    end
    def multiply(v)
      return Value.new(@red * v.red, @green * v.green, @blue * v.blue)
    end
    def multiply_with_scalar(s)
      return Value.new(@red * s, @green * s, @blue * s)
    end
    def self.from_int(i)
      return Value.new((i >> 16) & 0xff,
                       (i >> 8) & 0xff,
                       (i >> 0) & 0xff)
    end
    def to_i
      Integer(@blue) << 16 | Integer(@green) << 8 | Integer(@red)
    end
    def clamp_one(v)
      return 255 if v > 255
      return 0 if v < 0
      return v
    end
    def clamp
      return Value.new(clamp_one(@red), clamp_one(@green), clamp_one(@blue))
    end
    def to_s
      "#{@red}, #{@green}, #{@blue}"
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
    def to_s
      @values.join(', ')
    end
  end

  class Generator
    def process(channel)
      raise 'process(channels) not implemented'
    end
    def set(params)
      raise 'set(params) not implemented'
    end
  end
end

