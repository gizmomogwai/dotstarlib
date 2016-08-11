require 'json'

require 'sinatra'
require 'dotstarlib'
#require 'dotstar'

get '/filters' do
  DotStarLib::Filter.filters.sort.inject({}) { |memo, data|
    memo[data.first] = data[1][:params]
    memo
  }.to_json
end

#STRIP_SIZE = 1
#
#filters = Array.new
#
#class FakeStrip
#  def initialize(size)
#    @pixels = Array.new(size)
#  end
#  def set_pixel(idx, v)
#    @pixels[idx] = v
#  end
#  def refresh
#    puts @pixels
#  end
#end
#
##strip = DotStarStrip.new(STRIP_SIZE)
#strip = FakeStrip.new(STRIP_SIZE)
#filters << DotStarLib::SinFilter.new.set(frequency: 2, speed: 1)
##filters << DotStarLib::ColorFilter.new.set(color: 0xff0000)
#
#while true
#  data = Array.new(STRIP_SIZE)
#  data = filters.reduce([Array.new(STRIP_SIZE)]) {|data, filter|
#    filter.process(data)
#  }
#
#  data.first.each_with_index { |v, i|
#    strip.set_pixel(i, v)
#  }
#  strip.refresh
#end
