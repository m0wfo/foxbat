import java.net.InetSocketAddress
import org.jboss.netty.channel.socket.nio.NioServerSocketChannelFactory
import org.jboss.netty.bootstrap.ServerBootstrap
require_relative 'pipeline'
require_relative 'security'

module Foxbat

  class Server

    def initialize(host, port, klass, options, &block)
      if options[:secure]
        @context = Security.setup_ssl_context(options[:keystore])
      end
      
      @address = InetSocketAddress.new(host, port)
      @pipeline = Pipeline.new(klass, options, @context, &block)
    end

    def start(threadpool)
      @factory = NioServerSocketChannelFactory.new(threadpool, threadpool)
      @bootstrap = ServerBootstrap.new(@factory)
      @bootstrap.setPipelineFactory(@pipeline)
      @bootstrap.bind(@address)
    end

    def stop
      @bootstrap.releaseExternalResources
    end
  end
  
end
