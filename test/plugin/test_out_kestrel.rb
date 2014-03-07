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
    d = create_driver

    assert_equal 'localhost', d.instance.host
    assert_equal 22133, d.instance.port
    assert_equal "fluent-test", d.instance.queue
    d.run do
      sleep 2
    end
    d.instance.kestrel.flush("fluent-test")
  end

  def test_format

    # defalut
    d1 = create_driver
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    d1.emit({"a"=>1}, time)
    d1.emit({"a"=>2}, time)
    d1.expect_format(["test\t", "2011-01-02T13:14:15Z\t", {"a"=>1}].to_msgpack)
    d1.expect_format(["test\t", "2011-01-02T13:14:15Z\t", {"a"=>2}].to_msgpack)
    d1.run

    # time-format
    d2 = create_driver( CONFIG + %[
      time_format %Y-%m-%d %H-%M-%S
    ])
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    d2.emit({"a"=>1}, time)
    d2.emit({"a"=>2}, time)
    d2.expect_format(["test\t", "2011-01-02 13-14-15\t", {"a"=>1}].to_msgpack)
    d2.expect_format(["test\t", "2011-01-02 13-14-15\t", {"a"=>2}].to_msgpack)
    d2.run

    # remove tag, time
    d3 = create_driver( CONFIG + %[
      output_include_time false
      output_include_tag  false
    ])
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    d3.emit({"a"=>1}, time)
    d3.emit({"a"=>2}, time)
    d3.expect_format(["", "", {"a"=>1}].to_msgpack)
    d3.expect_format(["", "", {"a"=>2}].to_msgpack)
    d3.run

    # remove tag, use separator
    d4 = create_driver( CONFIG + %[
      output_include_tag  false
      field_separator COMMA
    ])
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    d4.emit({"a"=>1}, time)
    d4.emit({"a"=>2}, time)
    d4.expect_format(["", "2011-01-02T13:14:15Z,", {"a"=>1}].to_msgpack)
    d4.expect_format(["", "2011-01-02T13:14:15Z,", {"a"=>2}].to_msgpack)
    d4.run
    d4.instance.kestrel.flush("fluent-test")
  end

  def test_write
    d = create_driver
    time = Time.parse("2011-01-02 13:14:15 UTC").to_i

    d.emit({"a"=>3}, time)
    d.run

    get_opt = { :raw => true }.freeze

    #assert_equal "2011-01-02T13:14:15Z\ttest\t{\"a\":1}", d.instance.kestrel.get("fluent-test", opts=get_opt)
    #assert_equal "2011-01-02T13:14:15Z\ttest\t{\"a\":2}", d.instance.kestrel.get("fluent-test", opts=get_opt)
    assert_equal "2011-01-02T13:14:15Z\ttest\t{\"a\":3}", d.instance.kestrel.get("fluent-test", opts=get_opt)
    d.instance.kestrel.flush("fluent-test")
  end
end
