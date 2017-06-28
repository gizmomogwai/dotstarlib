require 'dotstarlib/generator'

module DotStarLib

  class SinGenerator < Generator
    def initialize(size)
      @size = size
      @phase = 0
    end

    def process(channel)
      @phase += @speed
      f_size = Float(@size)
      return Channel.new((0...@size).map {|i|
                           Value.new(
                             Math::sin(
                               Float(i + @phase) / f_size * 2.0 * Math::PI * @frequency))
                         })
    end

    def set(params)
      @phase = Float(get(params, :phase, @phase))
      @frequency = Float(get(params, :frequency, @frequency))
      @speed = Float(get(params, :speed, @speed))
      return self
    end

    def get(params, what, default_value)
      return params[what] if params.include?(what)
      what = what.to_s
      return params[what] if params.include?(what)
      return default_value
    end
  end
  
end
