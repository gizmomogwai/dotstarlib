require 'dotstarlib/filters'

module DotStarLib
  class DimFilter < Filter
    attr_accessor :factor
    def dim(v, factor)
      return (v * factor) / 0xff
    end
    def dim_value(v, factor)
      return Value.new(dim(v.red, factor), dim(v.green, factor), dim(v.blue, factor))
    end
    def process(channel)
      c = channel.values.map { |value|
        dim_value(value, @factor)
      }
      return Channel.new(c)
    end
    def set(params)
      @factor = params[:factor]
      return self
    end
    register("Dim", [:factor])
  end
end
