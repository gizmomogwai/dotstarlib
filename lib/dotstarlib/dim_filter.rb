require 'dotstarlib/filters'

module DotStarLib
  class DimFilter < Filter
    attr_accessor :factor
    def dim_channel(c, factor)
      return (c * factor) / 0xff
    end
    def process(channels)
      return channels.map { |channel|
        channel.map {|c|
          dim_channel(c, @factor)
        }
      }
    end
    def set(params)
      @factor = params[:factor]
      return self
    end
    register("Dim", [:factor])
  end
end
