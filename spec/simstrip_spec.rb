require 'fox16'
require 'fox16/colors'
include Fox
include Responder

describe 'something' do
  it 'should light up' do
    app = FXApp.new
    app.enableThreads

    class LEDStrip < FXFrame
      PIXEL_SIZE = 10
      OFFSET = 1
      SIZE = 120
      def initialize(*args)
        super
        @colors = Array.new(SIZE, Fox.FXRGB(0, 0, 0))
        FXMAPFUNC(SEL_PAINT, 0, :onPaint)
      end
      def set_app(app)
        @app = app
      end
      def onPaint(sender, sel, event)
        begin 
          sdc = FXDCWindow.new(self)
          sdc.foreground = 0xffffff
          sdc.fillRectangle(0, 0, self.width, self.height)
          (1...SIZE).each_with_index {|v, i|
            sdc.foreground = @colors[i]
            sdc.fillRectangle(i*PIXEL_SIZE + OFFSET, OFFSET, PIXEL_SIZE-2*OFFSET, PIXEL_SIZE-2*OFFSET)
          }

          sdc.foreground = 0x000000
          (1...SIZE).each {|i|
            last = i > 0 ? @colors[i-1] : nil
            current = @colors[i]
            draw_line(sdc, i, last, current)
          }
          sdc.end
        rescue => e
          puts e
          puts e.backtrace
        end
      end

      def draw_line(sdc, i, last, current)
        return unless (last && current)
        
        x1 = (i-1)*PIXEL_SIZE + OFFSET + PIXEL_SIZE/2;
        x2 = (i)*PIXEL_SIZE + OFFSET + PIXEL_SIZE/2;
        y1 = 300 - (last & 0xff)
        y2 = 300 - (current & 0xff)
        sdc.drawLine(x1, y1, x2, y2)
      end

      def set_pixel(i, r, g, b)
        #        puts "set_pixel #{i} to #{v}"
        @colors[i] = Fox.FXRGB(r, g, b)#(v >> 24) & 0xff, (v >> 16) & 0xff, (v >> 0) & 0xff)
      end

      def refresh
        update(0, 0, getDefaultWidth, getDefaultHeight)
        @app.repaint
      end

      def getDefaultWidth
        120*PIXEL_SIZE
      end

      def getDefaultHeight
        300
      end

      def size
        return SIZE
      end
    end

    window = FXMainWindow.new(app, "Hello")
    led_strip = LEDStrip.new(window)
    led_strip.set_app(app)
    
    Thread.new {
      begin
        filters = Array.new
        sin1 = DotStarLib::SinFilter.new.set(phase: 10, frequency: 1.5, speed: 0)
        sin2 = DotStarLib::SinFilter.new.set(phase: 20, frequency: 4.3, speed: -1.7)
        sin3 = DotStarLib::SinFilter.new.set(phase: 30, frequency: 2.1, speed: 5)
        sin4 = DotStarLib::SinFilter.new.set(frequency: 7, speed: -3.2)
        sin5 = DotStarLib::SinFilter.new.set(frequency: 3, speed: -2.1)
        sin6 = DotStarLib::SinFilter.new.set(frequency: 1, speed: 2.7)
        sin6 = DotStarLib::SinFilter.new.set(frequency: 1, speed: 2) 
        filters << DotStarLib::SumFilter.new([
                                               sin1,
                                               sin2,
                                               sin3,
                                               sin4,
                                               sin5,
                                               sin6
                                             ])
        filters << DotStarLib::DimFilter.new.set(factor: 32)
        
        while true
          channel = filters.reduce(Channel.new(Array.new(led_strip.size, Value.new(0,0,0)))) { |data, filter|
            filter.process(data)
          }
          for i in 0...channel.size
            v = channel.values[i]
            led_strip.set_pixel(i, [255, v.red].min, [255, v.green].min, [255, v.blue].min)
          end
          led_strip.refresh
          sleep 0.1
        end
      rescue => e
        puts e
      end
    }
    
    app.create
    window.show
    app.run

  end
end
