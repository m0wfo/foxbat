import java.nio.ByteBuffer

module EventMachine
  
  class Connection

    BUF_SIZE = 256

    attr_accessor :channel, :block, :ssl_engine
    attr_reader :open_time, :close_time

    def peername
      @channel.getRemoteAddress
    end

    def send_data(data)
      arr = data.to_java_bytes
      buf = ByteBuffer.allocate(arr.length)
      buf.put(arr)
      buf.flip

      @channel.write(buf)
    end

    def post_init; end

    def server_post_init
      @open_time ||= Time.now.to_i
    end

    def unbind; end

    def start_tls(args={})
      @ssl_session ||= @ssl_engine.getSession
      @app_buf ||= @ssl_session.getApplicationBufferSize
      @net_buf ||= @ssl_session.getPacketBufferSize
    end

    def receive_data(data)
      puts 'Incoming data...'
    end

    def close_connection(after_writing=false)
      if after_writing == false
        @channel.close
      else
        @channel.shutdownInput
        @channel.shutdownOutput
      end
      @close_time = Time.now.to_i
    end

    def close_connection_after_writing
      close_connection(true)
    end

    def read_channel(buffer=nil, app_bb=nil)

      @block.call(self)

      if buffer.nil?
        if @ssl_engine
          bb = ByteBuffer.allocate(@net_buf)
          app_bb = ByteBuffer.allocate(@app_buf)
          bb.clear
          app_bb.clear
          return read_channel(bb, net_bb)
        else
          bb = ByteBuffer.allocate(BUF_SIZE)
          bb.clear
          return read_channel(bb)
        end
      end

      reader = Foxbat::Handler.new(@channel) do |c,br|
        if br == -1
          c.close
          self.unbind
        else
          p @ssl_engine.getHandshakeStatus
          
          buffer.flip
          str = btos(buffer)

          buffer.clear
          buffer.rewind

          self.receive_data(str)
          read_channel(buffer)
        end
      end

      @channel.read(buffer, nil, reader)
    end

    private

    def btos(buf)
      return String.from_java_bytes(buf.array[buf.position..(buf.limit-1)])
    end
  end
end
