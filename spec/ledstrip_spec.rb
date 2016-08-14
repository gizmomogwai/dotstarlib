require 'dotstar'

require 'dotstarlib'
include DotStarLib

def as_int(r, g, b)
  return (Integer(b) << 16) | (Integer(g) << 8) | Integer(r)
end
describe 'something' do
  it 'should light up' do
    
    led_strip = DotStarStrip.new(120)

    Thread.new {
      begin
        sin1 = SinGenerator.new.set(phase: 10, frequency: 1.5, speed: 1)
        sin2 = SinGenerator.new.set(phase: 20, frequency: 4.3, speed: 0.9)
        sin3 = SinGenerator.new.set(phase: 30, frequency: 2.1, speed: 0.5)
        sin4 = SinGenerator.new.set(frequency: 7, speed: -3.2)
        sin5 = SinGenerator.new.set(frequency: 3, speed: -2.1)
        sin6 = SinGenerator.new.set(frequency: 1, speed: 2.7)
        sum = SumGenerator.new([
                                 sin1,
                                 sin2,
                                 sin3,
                                 sin4,
                                 sin5,
                                 sin6
                               ])
        color = ColorizeGenerator.new(a, Value.new(0, 255, 0))
        clamp = ClampGenerator.new(color)
        while true
          channel = clamp.process(nil)
          for i in 0...channel.size
            v = channel.values[i]
            led_strip.set_pixel(i, v.red, v.green, v.blue)
          end
          led_strip.refresh
          sleep 0.01
        end
      rescue => e
        puts e
        puts e.backtrace
      end
    }
    
    while true
      sleep 1
    end

  end
end
