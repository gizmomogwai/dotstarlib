require 'json'

require 'sinatra'
require 'dotstarlib'

get '/filters' do
  DotStarLib::Filter.filters.sort.inject({}) { |memo, data|
    memo[data.first] = data[1][:params]
    memo
  }.to_json
end

STRIP_SIZE = 120

filters = Array.new

strip = DotStarStrip.new(STRIP_SIZE)
filters << SinFilter.new.set(frequency: 2)
filters << ColorFilter.new.set(0xff0000)

while true
  data = Array.new(STRIP_SIZE)
  data = filters.reduce([Array.new(STRIP_SIZE)]) {|data, filter|
    filter.process(data)
  }


  data.first.each_with_index { |v, i|
    strip.set_pixel(v, i)
  }
  strip.refresh
  puts :next
end
