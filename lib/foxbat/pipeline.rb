import org.jboss.netty.channel.Channels
import org.jboss.netty.channel.ChannelPipelineFactory

module Foxbat

  class Pipeline
    include ChannelPipelineFactory

    def initialize(handler)
      @handler = handler
    end

    def getPipeline
      return Channels.pipeline(@handler.new)
    end
    
  end

end
