#require 'rbtrace'
require 'rx_ruby'
require 'net/http'
require 'json'
require 'dotstar'
require 'thread'

class Pixel
  attr_reader :name, :index
  attr_accessor :job
  def initialize(name)
    @name = name
  end
  def to_s
    "Pixel {name=>#{name}}"
  end
end

class Pulse
  MAX = 0.08
  def initialize
    @delta = 0.001
    @pulse = 0.0
  end
  def next
    @pulse += @delta
    if @pulse > MAX
      @delta = -@delta
    elsif @pulse <= 0
      @pulse = 0
      @delta = -@delta
    end
    @pulse
  end

  def apply_to(job)
    if job.in_progress
      return apply(job.to_color, @pulse)
    end
    return apply(job.to_color, MAX)
  end
  def apply(color, brightness)
    r = Integer((color & 0xff) * brightness)
    g = Integer(((color >> 8) & 0xff) * brightness)
    b = Integer(((color >> 16) & 0xff) * brightness)
    return 0xff000000 | ((b << 16 )&0xff0000) | ((g << 8)&0xff00) | (r & 0xff)
  end
end

class Job
  attr_reader :name, :status, :in_progress
  def initialize(name, status, in_progress)
    @name = name
    @status = status
    @in_progress = in_progress
  end
  def to_s
    return "Job{name => #{@name}, status => #{@status}}"
  end
  def to_color
    status2color = {
      :ok => 0xff00ff00,
      :broken => 0xff0000ff,
      :disabled => 0xffff0000
    }
    res = status2color[@status]
    if !res
      puts "unknown status #{@status}"
      res = 0xff00ffff
    end
    return res
  end
end

def observe_server(server)
  RxRuby::Observable.timer(0, 1).map do |time|
    res = Net::HTTP.get(server, '/api/json')
    puts res
    res
  end
end

COLOR_TO_STATUS = {'blue' => :ok,
                   'red' => :broken,
                   'blue_anime' => :ok,
                   'red_anime' => :broken,
                   'disabled' => :disabled}
def color2status(color)
  return COLOR_TO_STATUS[color]
end

def color2progress(color)
  return color.include?('anime')
end


pixels = [
  Pixel.new('audi-cgw'),
  Pixel.new('AudiDataCollector'),
  Pixel.new('bdc-klocwork'),
  Pixel.new('server-monitor'),
  Pixel.new('LabNotes-Sync'),
  Pixel.new('Ubitricity')
]

queue = Queue.new

def get_jobs(server)
  string = Net::HTTP.get(server, '/api/json')
  return JSON.parse(string)['jobs'].map{ |j|
    Job.new(j['name'],
            color2status(j['color']),
            color2progress(j['color']))
  }
end

Thread.new do
  while true
    begin
      (get_jobs('jenkins') + get_jobs('cgw3')).each do |job|
        pixel = pixels.find{|p|p.name == job.name}
        if pixel
          queue.push({:pixel => pixel, :job => job})
        end
      end
      GC.start
      sleep(2)
    rescue Exception => e
      puts e
    end
  end
end

#cgw3 = observe_server('cgw3')
#jenkins = observe_server('jenkins')


#source = RxRuby::Observable.merge(cgw3, jenkins)
#         .concat_map(lambda do |json,i|
#                       JSON.parse(json)['jobs'].map{ |j|
#                         Job.new(j['name'],
#                                 color2status(j['color']),
#                                 color2progress(j['color']))}
#                     end)



#subscription = source.subscribe(
#lambda {|job|
#begin
#  pixel = pixels.find{|p|p.name == job.name}
#  if pixel
#    #      queue.push({:pixel => pixel, :job => job})
#    #        #strip.set_pixel(pixel.index, job.to_color).refresh
#  end
#rescue Exception => e
#  puts e
#end
#},
#lambda {|err|
#  puts 'Error: ' + err.to_s
#},
#lambda {
#  puts 'Completed'
#})

strip = DotStarStrip.new(60)
pulse = 0
delta = 1

pulse = Pulse.new
while true
  pulse.next
  while !queue.empty?
    update = queue.pop
    update[:pixel].job = update[:job]
  end

  pixels.each_with_index do |pixel, index|
    job = pixel.job
    if job
      strip.set_pixel(index * 3, pulse.apply_to(job))
    end
  end
  strip.refresh
  sleep(0.005)
end

while Thread.list.size > 1
  (Thread.list - [Thread.current]).each &:join
end
