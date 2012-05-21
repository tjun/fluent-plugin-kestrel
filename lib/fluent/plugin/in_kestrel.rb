module Fluent
  class KestrelOutput < Input
    Fluent::Plugin.register_output('kestrel', self)
    attr_reader :kestrel

    config_param :host,         :string,    :default => nil
    config_param :port,         :integer,   :default => 22133
    config_param :queue,        :string,    :default => nil
    config_param :tag,          :string     :default => nil

    config_param :raw,          :bool,      :default => true
    config_param :peek,         :bool,      :default => false
    config_param :timeout,      :integer,   :default => 10

    def initialize
      super
      require 'kestrel'
      require 'time'
    end

    def configure(conf)
      super

      unless @queue && @host
        raise ConfigError, "[kestrel config error]:'host' and 'queue' option is required."
      end
      unless @tag
        raise ConfigError, "[kestrel config error]:'tag' option is required."
      end
      @timef = TimeFormatter.new(@time_format, @localtime)
      @options = {
        :raw => @raw,
        :peek => @peek,
        :timeout => @timeout
      }.freeze
    end

    def start
      super

      @kestrel = Kestrel::Client.new(@host + ":" + @port.to_s)
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      @thread.join
      super
    end

    def run
      loop {
        data = @kestrel.get(@queue, @options)
        unless data
          sleep 1
        else
          Engine.emit(@tag, Engine.now, data)
        end
      }
    end
  end
end
