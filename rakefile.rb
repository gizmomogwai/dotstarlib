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
