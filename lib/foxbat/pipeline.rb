import org.jboss.netty.channel.Channels
import org.jboss.netty.channel.ChannelPipelineFactory
import org.jboss.netty.handler.ssl.SslHandler

require_relative 'security'

module Foxbat

  class Pipeline
    include ChannelPipelineFactory

    def initialize(handler, ssl_context=nil)
      @handler = handler
      @context = ssl_context
    end

    def getPipeline
      pipeline = Channels.pipeline
      if @context
        engine = Security.create_ssl_engine(@context)
        pipeline.addLast("ssl", SslHandler.new(engine))
      end
      pipeline.addLast("handler", @handler.new)
      pipeline
    end
    
  end

end
