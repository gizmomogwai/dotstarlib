require 'dotstarlib/filters'

module DotStarLib
  class SinFilter < Filter
    def process(channels)
      size = channels.first.length
      fSize = Float(size)
      channels.map {|c|
        a = Array.new(size)
        for i in 0...size
          a[i] = Math::sin(Float(i) / fSize * 2.0 * Math::PI * @frequency)
        end
        a
      }
    end
    def set(params)
      @frequency = params[:frequency]
      return self
    end
    register("Sin", [:frequency])
  end
end
