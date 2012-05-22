require 'helper'

class TestFluentPluginInKestrel < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    require 'fluent/plugin/in_kestrel'
  end

  CONFIG = %[
    type kestrel
    host localhost
    port 22133
    queue fluent-test
    tag fluent.test
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::KestrelInput).configure(conf)
  end

  def test_configure
    d = create_driver(%[
      type kestrel
      host localhost
      port 22133
      queue fluent-test
      tag   fluent.test
    ])

    assert_equal 'localhost', d.instance.host
    assert_equal 22133, d.instance.port
    assert_equal "fluent-test", d.instance.queue
    assert_equal "fluent.test", d.instance.tag
  end

 # def test_emit
  # ToDo
 # end
end
