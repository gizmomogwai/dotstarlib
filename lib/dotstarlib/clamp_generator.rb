require 'dotstarlib/generator'

module DotStarLib
  class ClampGenerator < Generator
    def initialize(generator)
      @generator = generator
    end

    def process(channel)
      return Channel.new(@generator.process(nil).values.map { |v|
                           v.clamp
                         })
    end
  end
end
