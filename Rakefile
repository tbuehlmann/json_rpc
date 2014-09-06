require 'bundler/gem_tasks'

desc 'Opens a Pry console with json_rpc required.'
task :console do
  require 'pry'
  require 'json_rpc'

  ARGV.clear
  Pry.start
end
