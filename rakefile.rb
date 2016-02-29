require 'rake/extensiontask'

Rake::ExtensionTask.new do |ext|
  ext.name = 'dotstar'
  ext.ext_dir = 'src/lib/ruby'
  ext.config_script = 'extconf.rb'
  ext.tmp_dir = 'tmp'
  ext.source_pattern = "*.{cpp}"
end

#task :default => "run"
