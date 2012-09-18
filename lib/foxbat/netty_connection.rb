import java.nio.ByteBuffer
import org.jboss.netty.buffer.ChannelBuffers
import org.jboss.netty.channel.SimpleChannelUpstreamHandler

module Foxbat

  class NettyConnection < SimpleChannelUpstreamHandler

    def initialize(connection)
      @connection = connection
      connection.netty_handler = self
      super()
    end

    def write(data)
      buf = ChannelBuffers.copiedBuffer(data, "UTF-8")
      @channel.write(buf)
    end

    def close
      
    end

    private
    
    def channelConnected(ctx, e)
      @pipeline = ctx.getPipeline
      @channel = e.getChannel
      @connection.post_init
    end

    def channelClosed(ctx, e)
      @connection.unbind
    end

    def messageReceived(ctx, e)
      data = e.getMessage.toString('UTF-8')
      @connection.receive_data(data)
    end

    def exceptionCaught(ctx, e)
      p e.toString
    end
  end

end
