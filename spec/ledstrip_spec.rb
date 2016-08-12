require 'dotstar'
require 'dotstarlib'

def as_int(r, g, b)
  return (Integer(r) << 16) | (Integer(g) << 8) | Integer(b)
end
describe 'something' do
  it 'should light up' do
    
    led_strip = DotStarStrip.new(120)

    Thread.new {
      begin
        filters = Array.new
        sin1 = DotStarLib::SinFilter.new.set(phase: 10, frequency: 1.5, speed: 1)
        sin2 = DotStarLib::SinFilter.new.set(phase: 20, frequency: 4.3, speed: 0.9)
        sin3 = DotStarLib::SinFilter.new.set(phase: 30, frequency: 2.1, speed: 0.5)
#        sin4 = DotStarLib::SinFilter.new.set(frequency: 7, speed: -3.2)
#        sin5 = DotStarLib::SinFilter.new.set(frequency: 3, speed: -2.1)
#        sin6 = DotStarLib::SinFilter.new.set(frequency: 1, speed: 2.7)
#        sin6 = DotStarLib::SinFilter.new.set(frequency: 1, speed: 2) 
        filters << DotStarLib::SumFilter.new([
                                               sin1,
                                               sin2,
                                               sin3,
  #                                             sin4,
   #                                            sin5,
    #                                           sin6
                                             ])
        filters << DotStarLib::DimFilter.new.set(factor: 32)
        
        while true
          channel = filters.reduce(DotStarLib::Channel.new(Array.new(led_strip.size, DotStarLib::Value.new(0,0,0)))) { |data, filter|
            filter.process(data)
          }
          for i in 0...channel.size
            v = channel.values[i]
            led_strip.set_pixel(i,
                                as_int([255, v.red/4].min,
                                       [255, v.green].min,
                                       [255, v.blue/4].min))
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
