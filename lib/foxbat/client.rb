import org.jboss.netty.channel.socket.nio.NioClientSocketChannelFactory
import org.jboss.netty.bootstrap.ClientBootstrap
require_relative 'generic_connection'

module Foxbat

  class Client

    def initialize(host, port, klass, options, &block)
      if options[:secure]
        @context = Security.setup_ssl_client_context
      end

      @group = DefaultChannelGroup.new
      @address = InetSocketAddress.new(host, port)
      @pipeline = Pipeline.new(klass, @group, true, options, @context, &block)
    end
        
    def start(threadpool)
      factory = NioClientSocketChannelFactory.new(threadpool, threadpool)
      @bootstrap = ClientBootstrap.new(factory)
      @bootstrap.setPipelineFactory(@pipeline)
      @bootstrap.setOption("child.tcpNoDelay", true)
      @bootstrap.setOption("child.keepAlive", true)
      @bootstrap.connect(@address)
    end
    
  end

end
