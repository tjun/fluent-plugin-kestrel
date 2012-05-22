$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'bundler'
require 'test/unit'
require 'shoulda'
require 'fluent/test'

if ENV['SIMPLE_COV']
    require 'simplecov'
    SimpleCov.start do
      add_filter 'test/'
      add_filter 'pkg/'
    end
end

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

class Test::Unit::TestCase
end
