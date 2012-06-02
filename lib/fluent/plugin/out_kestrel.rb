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
    config_param :output_include_tag,   :bool,  :default => true
    config_param :output_include_time,  :bool,  :default => true
    config_param :remove_prefix,    :string ,   :default => nil
    config_param :field_separator,  :string, :default => nil

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
      @timef = TimeFormatter.new(@time_format, @localtime)
      @f_separator = case conf['field_separator']
                     when 'SPACE' then ' '
                     when 'COMMA' then ','
                     else "\t"
                     end

      if @remove_prefix
        @remove_prefix_string = @remove_prefix + '.'
        @remove_prefix_length = @remove_prefix_string.length
      end

    end

    def start
      super

      @kestrel = Kestrel::Client.new(@host + ":" + @port.to_s)
    end

    def shutdown
      super
    end

    def format(tag, time, record)

      if tag == @remove_prefix or @remove_prefix and (tag[0, @remove_prefix_length] == @remove_prefix_string and tag.length > @remove_prefix_length)
        tag = tag[@remove_prefix_length..-1]
      end

      time_str = if @output_include_time
                   @timef.format(time) + @f_separator
                 else
                   ''
                 end
      tag_str = if @output_include_tag
                  tag + @f_separator
                else
                  ''
                end
      [tag_str, time_str, record].to_msgpack
    end

    def write(chunk)
      chunk.open { |io|
        begin
          MessagePack::Unpacker.new(io).each{ |tag, time, record|
            data = "#{time}#{tag}#{record.to_json}"

            @kestrel.set(@queue, data, ttl=@ttl, raw=@raw)
          }
        rescue EOFError
          # EOFError always occured when reached end of chunk.
        end
      }
    end
  end
end
