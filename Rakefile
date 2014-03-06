# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "fluent-plugin-kestrel"
  gem.homepage = "http://github.com/tjun/fluent-plugin-kestrel"
  gem.license = "Apache License, Version 2.0"
  gem.summary = %Q{fluentd input/output plugin for kestrel.}
  gem.description = %Q{fluentd input/output plugin for kestrel queue.}
  gem.email = "t.junichiro@gmail.com"
  gem.authors = ["Junichiro Takagi"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

#unless RUBY_VERSION =~ /^1\.8/
#  require 'simplecov'
#  SimpleCov.start do
#    add_filter '_test'
#  end
#end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "fluent-plugin-kestrel #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
