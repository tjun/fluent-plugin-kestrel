module Fluent
  class KestrelOutput < BufferedOutput
    Fluent::Plugin.register_output('kestrel', self)
    attr_reader :kestrel

    config_param :host,         :string,    :default => nil
    config_param :port,         :integer,   :default => 22133
    config_param :queue,        :string,    :default => nil
    config_param :ttl,          :integer,   :default => 0
    config_param :raw,          :bool,      :default => true
    config_param :time_format,  :string,    :default => nil



    def initialize
      super
      require 'kestrel'
      require 'time'
    end

    def configure(conf)
      super

      unless @queue && @host
        raise ConfigError, "[kestrel config error]:'host' and 'queue' parameter must be specified."
      end
      @timef = TimeFormatter.new(@time_format, @localtime)
    end

    def start
      super

      @kestrel = Kestrel::Client.new(@host + ":" + @port.to_s)
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      chunk.open { |io|
        begin
          MessagePack::Unpacker.new(io).each{ |tag, time, record|
            time_str = @timef.format(time)
            data = "#{time_str}\t#{tag}\t#{record.to_json}"

            @kestrel.set(@queue, data, ttl=@ttl, raw=@raw)
          }
        rescue EOFError
          # EOFError always occured when reached end of chunk.
        end
      }
    end
  end
end
