require 'helper'

class TestFluentPluginKestrel < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    require 'fluent/plugin/out_kestrel'
  end

  CONFIG = %[
    type kestrel
    host localhost
    port 22133
    queue test
  ]

  end

  def create_driver(conf = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::KestrelOutput).configure(conf)
  end

  def test_configure
    d = create_driver(%[
      type kestrel
      host localhost
      port 22133
      queue test
    ])

    assert_equal 'localhost', d.instance.host
    assert_equal 22133, d.instance.port
    assert_equal "test", d.instance.queue
  end

  def test_format
    d = create_driver
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    
    d.emit({"a"=>1}, time)
    d.emit({"a"=>2}, time)
    d.expect_format([time, {"a"=>1}].to_msgpack)
    d.expect_format([time, {"a"=>2}].to_msgpack)
    d.run
  end

  def test_write
#    d = create_driver
#    time = Time.parse("2011-01-02 13:14:15 UTC").to_i

#    d.emit({"a"=>2}, time)
#    d.emit({"a"=>3}, time)
#    d.run

#    assert_equal "2", d.instance.kestrel.hget("test.#{@time}.0", "a")
#    assert_equal "3", d.instance.redis.hget("test.#{@time}.1", "a")
  end
end
