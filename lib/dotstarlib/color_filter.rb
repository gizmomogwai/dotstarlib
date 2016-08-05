require 'dotstarlib/filters'

module DotStarLib
  class ColorFilter < Filter
    def process(channels)
      return Channel.new(Array.new(channels.size, @color))
    end
    def set(params)
      c = Integer(params[:color])
      @color = Value.new((c >> 16) & 0xff, (c >> 8) & 0xff, c & 0xff)
      return self
    end
    register("Color", [:color])
  end
end
