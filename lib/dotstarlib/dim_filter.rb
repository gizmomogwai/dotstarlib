require 'dotstarlib/filters'

module DotStarLib
  class DimFilter < Filter
    attr_accessor :factor
    def dim_channel(c, factor)
      return (c * factor) / 0xff
    end
    def process(data)
      return data.map{ |color|
        r = dim_channel( (color & 0xff), @factor)
        g = dim_channel( ((color >> 8) & 0xff), @factor)
        b = dim_channel( ((color >> 16) & 0xff), @factor)
        ((b << 16 )&0xff0000) | ((g << 8)&0xff00) | (r & 0xff)
      }
    end
    def set(params)
      @factor = params[:factor]
    end
    register("Dim", [:factor])
  end
end
