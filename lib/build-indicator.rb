require 'net/http'
require 'json'
require 'dotstar'
require 'thread'





config = ARGV[0] || 'default.rb'
require_relative config
pixels = use_pixels
puts "working with #{pixels}"

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
      jenkins_jobs = get_jobs('jenkins')
      cgw3_jobs = get_jobs('cgw3')
      all_jobs = jenkins_jobs + cgw3_jobs
      all_jobs.each do |job|
        pixel = pixels.find{|p|p.name == job.name}
        if pixel
          queue.push({:pixel => pixel, :job => job})
        end
      end
      queue.push({:pixel => pixels[-2], :job => Job.new('@jenkins', :machine, jenkins_jobs.find{|j|j.in_progress} != nil)})
      queue.push({:pixel => pixels[-1], :job => Job.new('@cgw3', :machine, cgw3_jobs.find{|j|j.in_progress} != nil)})
      GC.start
      sleep(2)
    rescue Exception => e
      puts e
    end
  end
end

strip = DotStarStrip.new(60)

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
      strip.set_pixel((index+1), pulse.apply_to(job))
    end
  end
  strip.refresh
  sleep(1.0 / 30.0)
end

while Thread.list.size > 1
  (Thread.list - [Thread.current]).each &:join
end
