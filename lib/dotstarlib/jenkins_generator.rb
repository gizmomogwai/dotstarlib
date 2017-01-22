require 'dotstarlib/generator'
module DotStarLib
  class NoPulse
    def next
    end
    def apply_to(job)
      return job.to_color
    end
  end
  class Pulse
    MAX = 0.04
    def initialize
      @delta = 0.002
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

  class Server
    attr_reader :name, :jobs, :job
    def initialize(connect_string)
      parts = connect_string.split('@')
      user_pass = parts.first.split(':')
      @username = user_pass.first
      @basic_auth = user_pass[1]
      @name = parts[1]
      @last_update = Time.new(0)
    end
    def update()
      require 'json'
      now = Time.now
      if now - @last_update > 10
        uri = URI("http://#{@name}/api/json")
        puts "URI: #{uri}"
        req = Net::HTTP::Get.new(uri)
        req.basic_auth(@username, @basic_auth)
        res = Net::HTTP.start(uri.hostname, uri.port) {|http|
          http.request(req)
        }
        string = res.body #Net::HTTP.get(@name[1..-1], '/api/json')
        puts string
        @jobs = JSON.parse(string)['jobs'].map{ |j|
          Job.normal_job(j['name'],
                         j['color'],
                         j['color'])
        }
        @job = Job.new(@name, :machine, @jobs.find{|j|j.in_progress} != nil)
        @last_update = now
      end
      return @jobs
    end
    def to_s
      "Server(#{@name})"
    end
  end

  class JenkinsGenerator < Generator

    def server_job_name(server)
      return "@#{server}"
    end

    def initialize(size, servers, jobs, pulse)
      @size = size
      @servers = servers.map{|connect_string| Server.new(connect_string)}
      @pixels = jobs.map{|j|Pixel.new(j)} + servers.map{|s|Pixel.new("@#{s}")}
      @pulse = pulse
    end
    
    def process(channel)
      begin
        @pulse.next

        server_jobs = @servers.map {|s|s.update()}
        all_jobs = server_jobs.flatten
        @pixels.each do |pixel|
          # todo ... get current value of job and current value of server pixels
          pixel.job =
            if pixel.server_pixel?()
              server = @servers.find {|s|
                s.name == pixel.name
              }

              raise "could not find server for pixel #{pixel}" unless server
              server.job
            else
              res = all_jobs.find {|j| j.name == pixel.name}

              raise "could not find a job for pixel: #{pixel}" unless res
              res
            end
        end
        return Channel.new(@pixels.map{|pixel| Value.from_int(@pulse.apply_to(pixel.job)) })
      rescue => e
        puts e
        puts e.backtrace
      end
    end

    def set(params)
      @jobs = params[:jobs].split(' ')
      return self
    end
  end
  GREEN = 0xff00ff00
  RED = 0xffff0000
  BLUE = 0xff0000ff
  PINK = 0xffff00ff
  GREY = 0xff707070
  DARK_GREY = 0xff303030
  ORANGE = 0xff00a5ff

  class Pixel
    attr_reader :name, :index
    attr_accessor :job
    def initialize(name)
      @name = name
    end
    def server_pixel?()
      return @name[0] == '@'
    end
    def to_s
      "Pixel {name=>#{name}, job=>#{job}}"
    end
  end

  class Job
    attr_reader :name, :status, :in_progress
    def self.machine_job(name, in_progress)
      return Job.new(name, :machine, in_progress)
    end
    def self.normal_job(name, status, in_progress)
      return Job.new(name, color2status(status), color2progress(in_progress))
    end
    def initialize(name, status, in_progress)
      @name = name
      @status = status
      @in_progress = in_progress
    end
    def to_s
      return "Job{name => #{name}, status => #{status}, progress => #{in_progress}}"
    end
    def to_color
      status2color = {
        :ok => GREEN,
        :broken => RED,
        :disabled => BLUE,
        :machine => PINK,
        :aborted => GREY,
        :unstable => ORANGE,
        :not_built => DARK_GREY
      }
      res = status2color[@status]
      if !res
        puts "unknown status #{@status} for job #{self}"
        res = 0xffffff00
      end
      return res
    end

    COLOR_TO_STATUS = {'blue' => :ok,
                       'red' => :broken,
                       'blue_anime' => :ok,
                       'red_anime' => :broken,
                       'disabled' => :disabled,
                       'aborted' => :aborted,
                       'yellow' => :unstable,
                       'notbuilt' => :not_built
                      }
    def self.color2status(color)
      color = color.to_s.split('_').first
      res = COLOR_TO_STATUS[color]
      if res == nil
        puts "unknown color #{color}"
      end
      res
    end

    def self.color2progress(color)
      return color.to_s.include?('anime')
    end
  end
end
