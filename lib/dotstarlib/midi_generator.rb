require 'dotstarlib/generator'

module DotStarLib
  class MidiGenerator < Generator
    def initialize(size)
      @size = size
      @channel = Channel.new(Array.new(size) {|idx|Value.new(0)})
    end
    def update(pitch, velocity)
      @channel.values[pitch] = Value.new(velocity)
    end
    def process(channel)
      return @channel
    end
  end
end
