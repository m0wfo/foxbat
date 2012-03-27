import java.nio.ByteBuffer
import javax.net.ssl.SSLEngineResult::Status
import javax.net.ssl.SSLEngineResult::HandshakeStatus

module EventMachine
  
  class Connection

    BUF_SIZE = 256

    attr_accessor :channel, :block, :ssl_engine
    attr_reader :open_time, :close_time

    def peername
      @channel.getRemoteAddress
    end

    def send_data(data)
      @channel.write(ByteBuffer.wrap(data.to_java_bytes))
    end

    def post_init; end

    def server_post_init
      @open_time ||= Time.now.to_i
    end

    def unbind; end

    # start_tls is a no-op. The server decides when to initiate it.
    def start_tls(args={}); end

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

    def read_channel(buffer=nil)

      @block.call(self)

      if buffer.nil?
        if @ssl_engine
          return read_ssl_channel
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

    def read_ssl_channel(buffer=nil, app_buffer=nil, &block)

      if buffer.nil?
        setup_ssl
        bb = ByteBuffer.allocate(@net_buf)
        app_bb = ByteBuffer.allocate(@app_buf)
        bb.clear
        app_bb.clear
        return read_ssl_channel(bb, app_bb)
      end

      ssl_reader = Foxbat::Handler.new(@channel) do |c,br|
        if br == -1
          c.close
          self.unbind
        else
          buffer.flip
          if block_given?
            p 'BLOCK'
            block.call(buffer, app_buffer)
          else
            process_ssl(@ssl_engine.getHandshakeStatus, buffer, app_buffer)
          end
        end
      end

      @channel.read(buffer, nil, ssl_reader)
    end

    def btos(buf)
      return String.from_java_bytes(buf.array[buf.position..(buf.limit-1)])
    end

    def process_ssl(result, n_b=nil, a_b=nil)
      if result.is_a?(SSLEngineResult)
        result = result.getHandshakeStatus
      end
      
      case result
      when HandshakeStatus::NEED_TASK
        p 'handshake tasks remaining'
        task = @ssl_engine.getDelegatedTask
        if !task.nil?
          work = Proc.new do
            task.run
            process_ssl(@ssl_engine.getHandshakeStatus, n_b, a_b)
          end

          EM.executor.execute(work)
        end
      when HandshakeStatus::NEED_WRAP
        p 'wrap'
        n_b.compact
        res = @ssl_engine.wrap(a_b, n_b)
        case res.getStatus
        when Status::OK
          p 'wrap ok'
          n_b.flip
          send_ssl_data(n_b)
          
          process_ssl(@ssl_engine.getHandshakeStatus, n_b, a_b)
        when Status::CLOSED
          p 'closed'
        when Status::BUFFER_OVERFLOW
          p 'over'
        when STATUS::BUFFER_UNDERFLOW
          p 'under'
        end
      when HandshakeStatus::NEED_UNWRAP
        p 'unwrapBUM!'
        read_ssl_channel do |net,app|
          p 'in block'
          res = @ssl_engine.unwrap(net, app)
          case res.getStatus
          when Status::OK
            p 'ok'
            process_ssl(res, net, app)
          when Status::CLOSED
            p 'closed'
          when Status::BUFFER_OVERFLOW
            p 'over'
          when Status::BUFFER_UNDERFLOW
            p 'under'
          end
        end
      when HandshakeStatus::NOT_HANDSHAKING
        p 'not handshaking'
        res = @ssl_engine.unwrap(n_b, a_b)
        process_ssl(res, n_b, a_b)
      when HandshakeStatus::FINISHED
        p 'done'
      end
    end

    def send_ssl_data(data)
      @channel.write(data)
    end

    def setup_ssl
      @ssl_session ||= @ssl_engine.getSession
      @app_buf ||= @ssl_session.getApplicationBufferSize
      @net_buf ||= @ssl_session.getPacketBufferSize
    end

  end
end
