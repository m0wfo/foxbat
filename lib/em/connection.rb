import java.nio.ByteBuffer
import org.jboss.netty.buffer.ChannelBuffers
import org.jboss.netty.channel.SimpleChannelUpstreamHandler

module EventMachine
  
  class Connection < SimpleChannelUpstreamHandler

    def send_data(data, &block)
      buf = ChannelBuffers.copiedBuffer(data, "UTF-8")
      future = @channel.write(buf)
      return if block_given?
    end

    def post_init; end

    def unbind; end

    def start_tls(args={}); end

    def receive_data(data)
      puts 'Incoming data...'
    end

    def close_connection(after_writing=false)
    end

    def close_connection_after_writing
      close_connection(true)
    end

    def get_peername
      addr = @channel.getRemoteAddress
      [addr.getPort, addr.getHostString]
    end

    private

    # The netty channel callbacks

    def channelConnected(ctx, e)
      @pipeline = ctx.getPipeline
      @channel = e.getChannel
      post_init
    end

    def messageReceived(ctx, e)
      data = e.getMessage.toString('UTF-8')
      receive_data(data)
    end

    def exceptionCaught(ctx, e)
      p e.toString
    end

  end
end
