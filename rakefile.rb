require 'rake/extensiontask'

Rake::ExtensionTask.new do |ext|
  ext.name = 'dotstar'
  ext.ext_dir = 'src/lib/ruby'
  ext.config_script = 'extconf.rb'
  ext.tmp_dir = 'tmp'
  ext.source_pattern = "*.{cpp}"
end

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'compile native testprogram'
task :compile_test do
  sh "g++ -std=c++11 -Isrc/lib/cpp src/main/cpp/main.cpp -o test.exe"
end

desc 'compile native off'
task :compile_off do
  sh "g++ -std=c++11 -Isrc/lib/cpp src/main/cpp/off.cpp -o off.exe"
end

desc 'list with httpie'
task :presets do
  sh "http http://osmc.local:4567/presets"
end

desc 'activate on preset'
task :activate do
  sh "http -v --form http://osmc.local:4567/activate id=3"
end

desc 'off'
task :off do
  sh "http -v --form http://osmc.local:4567/activate id=0"
end

desc 'set a value of the activated preset'
task :set do
  sh "http -v --form http://osmc.local:4567/set color1=ff0000"
end
