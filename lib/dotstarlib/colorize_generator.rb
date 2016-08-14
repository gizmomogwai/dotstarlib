require 'dotstarlib/generator'

module DotStarLib
  class ColorizeGenerator < Generator
    def initialize(generator, value)
      @generator = generator
      @value = value
    end

    def process(channel)
      return Channel.new(@generator.process(nil).values.map { |v|
                           @value.multiply_with_scalar(v.red)
                         })
    end

    def set(params)
      @value = params[:value] || Value.new(1.0, 0.0, 0.0)
      return self
    end
  end
end
