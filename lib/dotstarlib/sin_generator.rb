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
      @phase = params[:phase] || 0
      @frequency = params[:frequency] || 1
      @speed = params[:speed] || 0
      return self
    end

    # register("Sin", [:frequency, :speed, :phase ])
  end
end
