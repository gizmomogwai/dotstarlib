require 'fox16'
require 'fox16/colors'
include Fox
include Responder

require 'dotstarlib'
include DotStarLib

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
        sin1 = SinGenerator.new(led_strip.size).set(phase: 0, frequency: 1, speed: 0)
        sin2 = SinGenerator.new(led_strip.size).set(phase: 0, frequency: 2, speed: 0)
        sum = SumGenerator.new([
                                 sin1,
                                 sin2,
                                 sin3,
                                 sin4,
                                 sin5,
                                 sin6
                                             ])
        a = sum
        color = ColorizeGenerator.new(a, Value.new(255, 255, 0))
        clamp = ClampGenerator.new(color)
        while true
          channel = clamp.process(nil)
          for i in 0...channel.size
            v = channel.values[i]
            led_strip.set_pixel(i, [255, v.red].min, [255, v.green].min, [255, v.blue].min)
          end
          led_strip.refresh
          sleep 0.1
        end
      rescue => e
        puts e
        puts e.backtrace
      end
    }
    
    app.create
    window.show
    app.run

  end
end
