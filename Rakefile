require "bundler/gem_tasks"
require 'rake'
require 'yard'
require 'yard/rake/yardoc_task'

desc 'Generate documentation for the public_activity plugin.'
YARD::Rake::YardocTask.new do |doc|
  doc.files = ['lib/**/*.rb']
end
