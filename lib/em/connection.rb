import java.nio.ByteBuffer
import java.nio.channels.AsynchronousFileChannel
import java.nio.file.Paths
import java.nio.file.StandardOpenOption
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

    def send_data(data, &block)
      bb = ByteBuffer.wrap(data.to_java_bytes)
      @channel.write(bb, nil, Foxbat::Handler.new(@channel) { block.call if block_given? })
    end

    def send_file_data(path, &block)
      file = Paths.get(path)
      options = java.util.HashSet.new
      options.add(StandardOpenOption::READ)
      file_channel = AsynchronousFileChannel.open(file, options, EM.executor)
      bb = ByteBuffer.allocate(file_channel.size)
      file_channel.read(bb, 0, nil, Foxbat::Handler.new(bb) { |buf, br|
                          buf.rewind
                          @channel.write(buf, nil, Foxbat::Handler.new(@channel) {
                                           block.call if block_given?
                                         }) })
    end

    def post_init; end

    def server_post_init
      @open_time = Time.now.to_i
      @secure = (@ssl_engine.nil? ? false : true)
      setup_ssl if @secure
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
        if @secure
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

    def new_buffer(size)
      buf = ByteBuffer.allocate(size)
      buf.clear
      buf
    end

    def read_ssl_channel(n_b=nil, a_b=nil, &block)
      n_b ||= new_buffer(@net_buf)
      a_b ||= new_buffer(@app_buf)
      
      ssl_reader = Foxbat::Handler.new(@channel) do |c,br|
        if br == -1
          c.close
          self.unbind
        else
          n_b.flip
          if block_given?
            block.call(n_b, a_b)
          else
            handshake(n_b, a_b)
          end
        end
      end

      @channel.read(n_b, nil, ssl_reader)
    end

    # ByteBuffer -> String
    def btos(buf)
      return String.from_java_bytes(buf.array[buf.position..(buf.limit-1)])
    end

    def transfer_data
      p 'done!'
      read_ssl_channel do |net,app|
        if @ssl_engine.getHandshakeStatus == HandshakeStatus::NOT_HANDSHAKING
          res = @ssl_engine.unwrap(net, app)
          handle_result(res, :ok => lambda {
                          app.compact
                          p res.to_s
                          p btos(app)
                        })
        else
          handshake(net, app)
        end
      end
    end

    def handshake(n_b=nil, a_b=nil, done=false)
      case @ssl_engine.getHandshakeStatus
      when HandshakeStatus::NEED_TASK
        p 'handshake tasks remaining'
        task = @ssl_engine.getDelegatedTask
        task.run if !task.nil?
        handshake(n_b, a_b)
      when HandshakeStatus::NEED_WRAP
        p 'wrap'
        n_b.clear
        res = @ssl_engine.wrap(a_b, n_b)
        handle_result(res,
                      :ok => lambda {
                        p 'wrap ok'
                        n_b.flip
                        send_ssl_data(n_b)
                        finished = (res.getHandshakeStatus == HandshakeStatus::FINISHED)
                        handshake(n_b, a_b, finished)
                      })

      when HandshakeStatus::NEED_UNWRAP
        res = @ssl_engine.unwrap(n_b, a_b)
        handle_result(res,
                      :ok => lambda { handshake(n_b, a_b) },
                      :underflow => lambda {
                        read_ssl_channel do |net, app|
                          res = @ssl_engine.unwrap(net,app)
                          handle_result(res, :ok => lambda { handshake(net, app) })
                        end
                        })

      when HandshakeStatus::NOT_HANDSHAKING
        p 'not handshaking'
        if done == true
          transfer_data
        else
          res = @ssl_engine.unwrap(n_b, a_b)
          handle_result(res,
                        :ok => lambda { handshake(n_b, a_b) })
        end
      end
    end

    # Handler for SSLEngine results
    def handle_result(result, options={})
      case result.getStatus # SSLEngineResult
      when Status::OK
        (options[:ok] || lambda { p 'ok' }).call
      when Status::BUFFER_OVERFLOW
        (options[:overflow] || lambda { p 'overflow' }).call
      when Status::BUFFER_UNDERFLOW
        (options[:underflow] || lambda { p 'underflow' }).call
      when Status::CLOSED
        (options[:closed] || lambda { p 'closed' }).call
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
