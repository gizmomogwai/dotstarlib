require 'dotstarlib/generator'
require 'time'

module DotStarLib
  class Moment
    attr_accessor :hour, :minute, :second
    def initialize(h, m, s=0)
      @hour = h
      @minute = m
      @second = s
    end
    def self.from(str)
      return Moment.new(*str.split(':').map{|i|Integer(i)})
    end
    def self.now
      dt = DateTime.now
      return Moment.new(dt.hour, dt.minute, dt.second)
    end
    def to_s
      return sprintf("%02d:%02d:%02d", hour, minute, second)
    end
    def delta_to(other)
      res = (other.hour - hour)*3600 + (other.minute - minute)*60 + (other.second - second)
      if res > 12*3600
        return res - 24*3600
      elsif res < -12 * 3600
        return res + 24*3600
      end
      return res
    end
  end

  # processed values from the provided generator or just uses the values provided in process
  class TimedFadeGenerator < Generator
    def initialize(generator=nil)
      @generator = generator
      @alarm = Moment.new(7, 0)
      @fade = 300
    end

    def process(channel)
      m = @time || Moment.now
      f = factor_for(m, @alarm, @fade)
      channel = @generator.process(nil) if @generator
      return Channel.new(channel.values.map { |v| v.multiply_with_scalar(f) })
    end

    # calculates a fading factor for a time in relation to an alarm
    # if the current time is before the alarm, it is faded from 0 to 1
    # with the fade distance
    # if the current time is after the alarm, it is maxed for fade-time
    def factor_for(current, alarm, fade)
      d = current.delta_to(alarm)
      if d == 0 # alarm
        return 1.0
      elsif d > 0 # alarm is coming
        if d > fade
          return 0.0
        end
        return Float(fade - d) / Float(fade)
      else
        if -d > fade
          return 0.0
        end
        return 1.0
      end
    end

    # takes hash pf :alarm, :fade, :time
    def set(params)
      v = params[:alarm]
      @alarm = Moment.from(params[:alarm])
      @fade = Integer(params[:fade])
      @time = params[:time]
      if @time
        @time = Moment.from(@time)
      end
      puts "Setting alarmtime to #{@alarm} with fading #{@fade} (simulated time: #{@time})"
      return self
    end
  end

end
