require 'dotstarlib/filters'

module DotStarLib
  class ColorFilter < Filter
    attr_accessor :color
    def set(params)
      @color = params[:color]
    end
    def process(data)
      return Array.new(data.length, @color)
    end
    register("Color", [:color])
  end
end
