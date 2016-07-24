require 'dotstarlib/filters'

module DotStarLib
  class ColorFilter < Filter
    def process(data)
      return Array.new(data.length, @color)
    end
    def set(params)
      @color = params[:color]
      return self
    end
    register("Color", [:color])
  end
end
