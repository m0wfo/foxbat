import java.nio.ByteBuffer
import javax.net.ssl.SSLEngineResult::HandshakeStatus

module EventMachine
  
  class Connection

    attr_accessor :channel, :ssl_engine, :block, :executor
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

    def unbind; end

    def set_time
      @open_time ||= Time.now.to_i
    end

    def start_tls(args={})
      # todo
    end

    def receive_data(data)
      p 'Incoming data...'
    end

    def close_connection(after_writing=false)
      @channel.close
      @close_time = Time.now.to_i
    end

    def read_channel(buffer=nil)
      
      @block.call(self)

#      @ssl_session ||= @ssl_engine.getSession
#      @abs ||= @ssl_session.getApplicationBufferSize
      #      @pbs ||= @ssl_session.getPacketBufferSize

      @abs ||= 256

      if buffer.nil?
        bb = ByteBuffer.allocate(@abs)
        bb.clear
        return read_channel(bb)
      end

      reader = Foxbat::Handler.new(@channel) do |c,br|
        if br == -1
          c.close
          self.unbind
        else
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
