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
      puts "ColorizeGenerator.set(#{params})"
      v = params[:value]
      m = v.match(/#..(......)/) ||
          v.match(/#(......)/) ||
          v.match(/..(......)/) ||
          v.match(/(......)/)

      i = Integer(m[1], 16)
      puts i
      @value = Value.from_int(i) || Value.new(1.0, 0.0, 0.0)
      puts @value
      puts "done"
      return self
    end
  end
end
