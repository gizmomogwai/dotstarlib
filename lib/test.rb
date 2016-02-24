require 'rx_ruby'
require 'net/http'
require 'json'
require 'dotstar'

class Job
  attr_reader :name, :status
  def initialize(name, status)
    @name = name
    @status = status
  end
  def to_s
    return "Job{name => #{@name}, status => #{@status}}"
  end
end

def observe_server(server)
  RxRuby::Observable.timer(0, 2).map do |time|
    Net::HTTP.get(server, '/api/json')
  end
end

jenkins = observe_server('jenkins')
cgw3 = observe_server('cgw3')

#source = RxRuby::Observable.merge(jenkins, cgw3).
source = jenkins.
         concat_map(lambda do |json,i|
                      color2status = {'blue' => :ok,
                                      'red' => :broken,
                                      'blue_anime' => :ok_building,
                                      'red_anime' => :broken_building,
                                      'grey' => :inactive}
                      jobs = JSON.parse(json)['jobs'].map{|j|Job.new(j['name'], color2status[j['color']])}
                      jobs
                    end)


strip = DotStarStrip.new(60)

class Pixel
  attr_reader :name, :index
  def initialize(name, index)
    @name = name
    @index = index
  end
end

pixels = [
  Pixel.new('audi-cgw', 0),
  Pixel.new('AudiDataCollector', 1),
  Pixel.new('bdc-klocwork', 2),
  Pixel.new('server-monitor', 3),
  Pixel.new('LabNotes-Sync', 4)
]

subscription = source.subscribe(
  lambda {|x|
    puts 'Next: ' + x.to_s
    p = pixels.find{|i|i.name == x.name}
    if p
      puts "found pixel #{p}"
      strip.set_pixel(p.index, 0xffff0000).refresh
    end
  },
  lambda {|err|
    puts 'Error: ' + err.to_s
  },
  lambda {
    puts 'Completed'
  })


while Thread.list.size > 1
  (Thread.list - [Thread.current]).each &:join
end
