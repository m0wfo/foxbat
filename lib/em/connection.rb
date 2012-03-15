import java.nio.ByteBuffer
import javax.net.ssl.SSLEngineResult::HandshakeStatus

module EventMachine
  
  class Connection

    attr_accessor :channel, :ssl_engine, :block, :executor

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

    def close_connection(after_writing=false)
      @channel.close
    end

    def read_channel(buffer=nil, memo="")
      
      @block.call(self)

      @ssl_session ||= @ssl_engine.getSession
      @abs ||= @ssl_session.getApplicationBufferSize
      @pbs ||= @ssl_session.getPacketBufferSize

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
          memo << str
          buffer.clear
          buffer.rewind

          if br == @abs
            read_channel(buffer, memo)
          else
            self.receive_data(memo)
            read_channel(buffer)
          end

        end
      end

      @channel.read(buffer, nil, reader)
    end

    private

    def btos(buf)
      return String.from_java_bytes(buf.array[buf.position..buf.limit])
    end
  end
end
