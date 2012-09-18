module EventMachine
  
  class Connection

    attr_writer :netty_handler

    def self.new(*args)
      allocate.instance_eval do
        initialize(*args)
        self
      end
    end

    def initialize(*args); end

    def send_data(data)
      @netty_handler.write(data)
    end

    def post_init; end

    def unbind; end

    def start_tls(args={}); end

    def receive_data(data)
      puts 'Incoming data...'
    end

    def close_connection(after_writing=false)
      @netty_handler.close
    end

    def close_connection_after_writing
      close_connection(true)
    end

    def get_peername
      @netty_handler.peername
    end

  end
end
