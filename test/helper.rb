$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'bundler'
require 'shoulda'

if ENV['SIMPLE_COV']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test/'
    add_filter 'pkg/'
  end
end

require 'test/unit'
require 'fluent/test'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'fluent/plugin/in_kestrel'
require 'fluent/plugin/out_kestrel'

class Test::Unit::TestCase
end
