require 'dotstarlib/filters'

module DotStarLib
  class SinFilter < Filter
    def initialize
      @phase = 0
    end

    def process(channel)
      @phase += @speed
      size = channel.size
      f_size = Float(size)

      values = (0...size).map {|i|
        v = (Math::sin(Float(i + @phase) / f_size * 2.0 * Math::PI * @frequency) + 1) * 127
        Value.new(v, v, v)
      }
      return Channel.new(values)
    end

    def set(params)
      @phase = params[:phase] || 0
      @frequency = params[:frequency] || 1
      @speed = params[:speed] || 0
      return self
    end

    register("Sin", [:frequency, :speed, :phase ])
  end
end
