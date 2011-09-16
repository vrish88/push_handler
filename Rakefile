# encoding: utf-8

require 'rubygems'
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "push_handler"
  gem.homepage = "http://github.com/vrish88/push_handler"
  gem.license = "MIT"
  gem.summary = %Q{Format push data in a format that Github services understands.}
  gem.description = %Q{This gem is for integreting a privately hosted repository with the open source Github services project.}
  gem.email = "michael.lavrisha@gmail.com"
  gem.authors = ["Michael Lavrisha"]

  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_runtime_dependency 'json', '~>1.5.0'
  gem.add_runtime_dependency 'grit', '~>2.0.0'
  gem.add_development_dependency "bundler", "~> 1.0.0"
  gem.add_development_dependency "jeweler", "~> 1.6.4"
  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec
