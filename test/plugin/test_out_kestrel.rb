require 'helper'

class TestFluentPluginOutKestrel < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    require 'fluent/plugin/out_kestrel'
  end

  CONFIG = %[
    type kestrel
    host localhost
    port 22133
    queue fluent-test
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::KestrelOutput).configure(conf)
  end

  def test_configure
    d = create_driver(%[
      type kestrel
      host localhost
      port 22133
      queue fluent-test
    ])

    assert_equal 'localhost', d.instance.host
    assert_equal 22133, d.instance.port
    assert_equal "fluent-test", d.instance.queue
    d.run
    d.instance.kestrel.flush("fluent-test")
  end

  def test_format
    d = create_driver
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i

    d.emit({"a"=>1}, time)
    d.emit({"a"=>2}, time)
    d.expect_format(["test", time, {"a"=>1}].to_msgpack)
    d.expect_format(["test", time, {"a"=>2}].to_msgpack)
    d.run
  end

  def test_write
    d = create_driver
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i

    d.emit({"a"=>3}, time)
    d.run

    get_opt = { :raw => true }.freeze

    assert_equal "2011-01-02T13:14:15Z\ttest\t{\"a\":1}", d.instance.kestrel.get("fluent-test", opts=get_opt)
    assert_equal "2011-01-02T13:14:15Z\ttest\t{\"a\":2}", d.instance.kestrel.get("fluent-test", opts=get_opt)
    assert_equal "2011-01-02T13:14:15Z\ttest\t{\"a\":3}", d.instance.kestrel.get("fluent-test", opts=get_opt)
    d.instance.kestrel.flush("fluent-test")
  end
end
