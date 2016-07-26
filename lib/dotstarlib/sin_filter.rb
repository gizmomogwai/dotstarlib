require 'dotstarlib/filters'

module DotStarLib
  class SinFilter < Filter
    def process(channels)
      require 'pp'
      pp channels
      s = channels.first.length
      puts channels.size
      puts s
      channels.map {|c|
        puts s
        a = Array.new(s)
        for i in 0...s
          a[i] = Math::sin(Float(i) / s * 2 * Math::PI * @frequency)
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
