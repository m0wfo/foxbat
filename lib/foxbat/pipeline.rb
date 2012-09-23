import org.jboss.netty.channel.Channels
import org.jboss.netty.channel.ChannelPipelineFactory
import org.jboss.netty.handler.ssl.SslHandler

require_relative 'security'
require_relative 'netty_connection'

module Foxbat

  class Pipeline
    include ChannelPipelineFactory

    HANDLER = "handler"
    SSL_HANDLER = "ssl"

    def initialize(handler, group, client, options={}, ssl_context=nil, &block)
      @options = options
      @handler = handler
      @client_mode = client

      if handler.class == Module
        @handler = Class.new(EM::Connection)
        @handler.send(:include, handler)
      end
      
      @group = group
      @block = block
      @context = ssl_context
    end

    def getPipeline
      pipeline = Channels.pipeline
      if @context
        engine = Security.create_ssl_engine(@context, @client_mode)
        pipeline.addLast(SSL_HANDLER, SslHandler.new(engine))
      end
      h = @handler.new(@options)
      @block.call(h) if @block
      connection = NettyConnection.new(h, @group)
      pipeline.addLast(HANDLER, connection)
      pipeline
    end

    def releaseExternalResources
      # todo
    end
  end

end
