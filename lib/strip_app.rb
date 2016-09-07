require 'json'
require 'sinatra/base'
require 'byebug'
require 'dotstarlib'
include DotStarLib
require 'dnssd'
begin
  require 'dotstar'
rescue
  puts "Warning: could not open dotstar native support => using sim"
  require 'dotstarsimulator'
end


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

class LedControl
  def initialize
    @led_strip = DotStarStrip.new(120)
    @queue = Queue.new
    @current_preset = Off.new
    Thread.new do
      while true
        begin
          msg = @queue.pop
          if msg[:preset]
            begin
              if @current_preset
                puts "stopping '#{@current_preset.name}'" 
                @current_preset.stop
              end
            rescue => e
              puts e.message
              puts e.backtrace
            end
            @current_preset = msg[:preset]
            puts "starting '#{@current_preset.name}'"
            @current_preset.start(@led_strip)
          end

          if msg[:params]
            @current_preset.set(msg[:params]) if @current_preset
          end
        rescue => e
          puts e
          puts e.backtrace
        end
      end
    end
  end
  def set_preset(preset)
    @queue.push({preset: preset})
  end
  def set_params(params)
    @queue.push({params: params})
  end
end

class Off
  def name
    return "Off"
  end
  def parameters
    return []
  end
  def set(params)
  end
  def start(led_strip)
    puts "starting off"
    for i in 0...led_strip.size
      led_strip.set_pixel(i, 0)
    end
    led_strip.refresh
  end
  def stop
    puts "stopping off"
    # nothing todo
  end
end

def update_strip(generator, led_strip)
  channel = generator.process(nil)
  for i in 0...channel.size
    v = channel.values[i]
    led_strip.set_pixel(i, v.to_i)
  end
  led_strip.refresh
end

class Puller
  def initialize(generator, led_strip)
    @generator = generator
    @led_strip = led_strip
    @finished = false
    @thread = Thread.new {
      run
    }
  end

  def run
    begin
      while !@finished
        update_strip(@generator, @led_strip)
        sleep 0.01
      end
    rescue => e
      puts e
      puts e.backtrace
    end
  end
    
  def stop_it
    @finished = true
    @thread.join
  end
  
end

class Sinuses
  def name
    return "Sinuses"
  end
  def parameters
    return [{type: :color, name: :color}]
  end
  def set(data)
    @color.set({value: data[:color]}) if @color
  end
  def start(led_strip)
    puts "starting sinuses"
    size = led_strip.size
    sin1 = SinGenerator.new(size).set(phase: 10, frequency: 1.5, speed: 1)
    sin2 = SinGenerator.new(size).set(phase: 20, frequency: 4.3, speed: 0.9)
    sin3 = SinGenerator.new(size).set(phase: 30, frequency: 2.1, speed: 0.5)
    sin4 = SinGenerator.new(size).set(frequency: 7, speed: -3.2)
    sin5 = SinGenerator.new(size).set(frequency: 3, speed: -2.1)
    sin6 = SinGenerator.new(size).set(frequency: 1, speed: 2.7)
    sum = SumGenerator.new([
                             sin1,
#                             sin2,
#                             sin3,
#                             sin4,
#                             sin5,
#                             sin6
                           ])
    @color = ColorizeGenerator.new(sum, Value.new(0, 255, 0))
    @generator = ClampGenerator.new(@color)
    @puller = Puller.new(@generator, led_strip)
  end
  def stop
    puts "stopping sinuses"
    @puller.stop_it if @puller
  end
end

class Pusher
  def initialize(&block)
    @block = block
    @finished = false
    @thread = Thread.new {
      run
    }
  end
  def run
    while !@finished
      begin
        @block.call
      rescue => e
        puts e.message
        puts e.backtrace
      end
    end
  end
  def stop
    @finished = true
    @thread.join
  end
end

class CKJenkins
  def name
    "CKJenkins"
  end
  def parameters
    return []
  end
  def set(data)
  end
  def start(led_strip)
    @generator = JenkinsGenerator.new(led_strip.size, ['cgw3'], ['audi-cgw', 'audi-cgw2', 'huawei-kernel'], Pulse.new)
    @puller = Puller.new(@generator, led_strip)
  end
  def stop
    puts "stopping sinuses"
    @puller.stop_it if @puller
  end
end

class Midi
  def initialize
    @queue = Queue.new
    @ip_and_port = "192.168.0.181:55554"
  end
  def name
    "Midi"
  end
  def parameters
    return [{type: :string, name: :ip_with_port}, {type: :color, name: :color}]
  end
  def set(data)
    @color.set({value: data[:color]}) if @color
  end
  def start(led_strip)
    midi_generator = MidiGenerator.new(led_strip.size)
    @color = ColorizeGenerator.new(midi_generator, Value.new(0, 255, 0))
    generator = ClampGenerator.new(@color)

    ip, port = @ip_and_port.split(':')
    port = Integer(port)
    @socket = TCPSocket.new(ip, port)
    
    @pusher = Pusher.new() {
      pitch, velocity = @socket.read(2).unpack('C C')
      midi_generator.update(pitch, velocity)
      update_strip(generator, led_strip)
    }
  end
  def stop
    @socket.close
    @pusher.stop
  end
end

class MyTcpSocket < TCPSocket
  def initialize(bind)
    @addr = bind
  end
  def port
    return 4567
  end
  def addr
    return [nil, @addr]
  end
end
class App < Sinatra::Base
  set :bind, "0.0.0.0"
  def initialize()
    super()
    puts "initialize: #{self}"
    @presets = Array.new
    @presets << Off.new
    @presets << Sinuses.new
    @presets << Midi.new
    @presets << CKJenkins.new
    @led_control = LedControl.new
  end

  get '/presets' do
    byebug
    @presets.each_with_index.map {|i, index|
      {
        id: index,
        name: i.name,
        parameters: i.parameters
      }
    }.to_json
  end

  post '/activate' do
    begin
      puts params
      preset = @presets[Integer(params['id'])]
      @led_control.set_preset(preset)
    rescue => e
      puts e.backtrace
      puts e
    end
  end

  post '/set' do
    puts "set parameters: #{params}"
    @led_control.set_params(params)
  end
#  
#  get '/filters' do
#    DotStarLib::Filter.filters.sort.inject({}) { |memo, data|
#      memo[data.first] = data[1][:params]
#      memo
#    }.to_json
##  end

  #get '/reset' do
  #  reset!
  #  @count += 1
  #  get '/add' do
  #    App.get "/get#{@count}" do
  #      "count is #{@count}"
  #    end
  #  end
  #end
  run! do |server|
    @announce = DNSSD.register(File.read('location.txt'), "_dotstar._tcp", nil, 4567)
  end
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
