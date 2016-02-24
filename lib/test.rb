require 'rx_ruby'
require 'net/http'
require 'json'
require 'dotstar'

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
    return status2color[@status] || 0xff00ffff
  end
end

def observe_server(server)
  RxRuby::Observable.timer(0, 2).map do |time|
    Net::HTTP.get(server, '/api/json')
  end
end

cgw3 = observe_server('cgw3')
jenkins = observe_server('jenkins')

def color2status(color)
  color2status = {'blue' => :ok,
                  'red' => :broken,
                  'blue_anime' => :ok,
                  'red_anime' => :broken,
                  'disabled' => :disabled}
  return color2status[color]
end

def color2progress(color)
  return color.include?('anime')
end

source = RxRuby::Observable.merge(cgw3, jenkins)
         .concat_map(lambda do |json,i|
                       JSON.parse(json)['jobs'].map{ |j|
                         Job.new(j['name'],
                                 color2status(j['color']),
                                 color2progress(j['color']))
                       }
                     end)



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

pixels = [
  Pixel.new('audi-cgw'),
  Pixel.new('AudiDataCollector'),
  Pixel.new('bdc-klocwork'),
  Pixel.new('server-monitor'),
  Pixel.new('LabNotes-Sync'),
  Pixel.new('Ubitricity')
]

require 'thread'
queue = Queue.new

subscription = source.subscribe(
  lambda {|job|
    begin
      pixel = pixels.find{|p|p.name == job.name}
      if pixel
        queue.push({:pixel => pixel, :job => job})
        #strip.set_pixel(pixel.index, job.to_color).refresh
      end
    rescue Exception => e
      puts e
    end
  },
  lambda {|err|
    puts 'Error: ' + err.to_s
  },
  lambda {
    puts 'Completed'
  })

strip = DotStarStrip.new(60)
pulse = 0
delta = 1

class Pulse
  def initialize
    @delta = 0.004
    @pulse = 0.0
  end
  def next
    @pulse += @delta
    if @pulse > 0.8
      @delta = -@delta
    elsif @pulse <= 0
      @pulse = 0
      @delta = -@delta
    end
  end

  def apply_to(job)
    if job.in_progress
      color = job.to_color
      r = Integer((color & 0xff) * @pulse)
      g = Integer(((color >> 8) & 0xff) * @pulse)
      b = Integer(((color >> 16) & 0xff) * @pulse)
      return 0xff000000 | ((b << 16 )&0xff0000) | ((g << 8)&0xff00) | (r & 0xff)
    end
    return job.to_color
  end
end

pulse = Pulse.new

while true
  pulse.next

  while !queue.empty?
    update = queue.pop
    update[:pixel].job = update[:job]
    #strip.set_pixel(update[:pixel].index, update[:job].to_color(pulse)).refresh
  end
  pixels.each_with_index do |pixel, index|
    job = pixel.job
    if job
      strip.set_pixel(index * 3, pulse.apply_to(job))
    end
  end
  strip.refresh
  sleep(0.01)
end

while Thread.list.size > 1
  (Thread.list - [Thread.current]).each &:join
end
