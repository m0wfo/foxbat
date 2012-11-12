import java.net.InetSocketAddress
import org.jboss.netty.channel.group.DefaultChannelGroup
import org.jboss.netty.channel.socket.nio.NioServerSocketChannelFactory
import org.jboss.netty.bootstrap.ServerBootstrap
require_relative 'pipeline'

module Foxbat

  class Server
    def initialize(host, port, klass, options, &block)
      if options[:secure]
        @context = Security.setup_ssl_context(options[:keystore])
      end

      @group = DefaultChannelGroup.new
      @address = InetSocketAddress.new(host, port)
      @pipeline = Pipeline.new(klass, @group, false, options, @context, &block)
    end
    
    def start(threadpool)
      sp = java.util.concurrent.Executors.newSingleThreadExecutor
      factory = NioServerSocketChannelFactory.new(sp, threadpool)
      @bootstrap = ServerBootstrap.new(factory)
      @bootstrap.setPipelineFactory(@pipeline)
      @bootstrap.setOption("child.tcpNoDelay", true)
      server_channel = @bootstrap.bind(@address)
      @group.add(server_channel)
    end

    def connection_count
      @group.size - 1 # -1 to exclude the server's channel
    end

    def stop
      @group.close.awaitUninterruptibly
    end
  end
  
end
