module Fluent
  class KestrelOutput < BufferedOutput
    Fluent::Plugin.register_output('kestrel', self)

    config_param :host,         :string,    :default => '127.0.0.1'
    config_param :port,         :integer,   :default => 22133
    config_param :queue,        :string,    :default => nil
    config_param :ttl,          :integer,   :default => 0
    config_param :raw,          :boolean,   :default => false


    def initialize
      super
      require 'kestrel'
    end

    def configure(conf)
      super

      unless @queue
        raise ConfigError, "'queue' parameter must be specified."
      end
    end

    def start
      super

      @kestrel = Kestrel::Client.new(@host + ":" @port)
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      "#{time}\t#{tag}\t#{record.to_json}"
    end

    def write(chunk)
      chunk.open{ |data|
          @kestrel.set(@queue, data, ttl=@ttl, raw=@raw)
        }
      }
    end
  end
end
