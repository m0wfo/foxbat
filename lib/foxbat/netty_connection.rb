import java.nio.ByteBuffer
import org.jboss.netty.buffer.ChannelBuffers
import org.jboss.netty.channel.SimpleChannelUpstreamHandler

module Foxbat

  class NettyConnection < SimpleChannelUpstreamHandler

    def initialize(connection, group)
      @connection = connection
      @group = group
      connection.netty_handler = self
      super()
    end

    def write(data, broadcast=false)
      data =  data.to_java_bytes if data.is_a?(String)
      buf = ChannelBuffers.copiedBuffer(data)

      recipient = broadcast ? @group : @channel
      recipient.write(buf)
    end

    def close
      @channel.close
    end

    private

    def channelOpen(ctx, e)
      @group.add(e.getChannel)
    end
    
    def channelConnected(ctx, e)
      @pipeline = ctx.getPipeline
      @channel = e.getChannel
      @connection.post_init
    end

    def channelClosed(ctx, e)
      @connection.unbind
    end

    def messageReceived(ctx, e)
      data = String.from_java_bytes(e.getMessage.array)
      @connection.receive_data(data)
    end

    def exceptionCaught(ctx, e)
      p e.toString
    end
  end

end
