import org.jboss.netty.channel.Channels
import org.jboss.netty.channel.ChannelPipelineFactory
import org.jboss.netty.handler.ssl.SslHandler

require_relative 'security'
require_relative 'netty_connection'

module Foxbat

  class Pipeline
    include ChannelPipelineFactory

    def initialize(handler, options={}, ssl_context=nil, &block)
      @options = options
      @handler = handler
      @block = block
      @context = ssl_context
    end

    def getPipeline
      pipeline = Channels.pipeline
      if @context
        engine = Security.create_ssl_engine(@context)
        pipeline.addLast("ssl", SslHandler.new(engine))
      end
      h = @handler.new(@options)
      @block.call(h) if @block
      connection = NettyConnection.new(h)
      pipeline.addLast("handler", connection)
      pipeline
    end
    
  end

end
