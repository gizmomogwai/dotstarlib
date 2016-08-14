require 'json'

require 'sinatra/base'
require 'byebug'
#require 'dotstarlib'
#require 'dotstar'




class Handler
  def initialize(count)
    @count = count
    puts "new handler with #{count}"
  end
  def run
    "handler with count #{@count}"
  end
  def register()
    h = self
    App.get("/get#{@count}") do
      h.run
    end
  end
end

class AddHandler
  def initialize(app)
    @count = 0
    @app = app
  end

  def run
    @count += 1
    @app.add_handler(Handler.new(@count))
  end
                     
  def register()
    h = self
    App.get("/add") do
      h.run
    end
  end
end

class App < Sinatra::Base
  def initialize
    puts "init app"
    @presets = []
    @presets << Preset.new()
  end

  get '/presets' do
  end

  post '/activate/:id' do
  end

  post '/set/:id' do
  end
  
  get '/filters' do
    DotStarLib::Filter.filters.sort.inject({}) { |memo, data|
      memo[data.first] = data[1][:params]
      memo
    }.to_json
  end

  #get '/reset' do
  #  reset!
  #  @count += 1
  #  get '/add' do
  #    App.get "/get#{@count}" do
  #      "count is #{@count}"
  #    end
  #  end
  #end
  
  run!
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
