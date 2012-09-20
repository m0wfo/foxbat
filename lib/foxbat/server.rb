import java.net.InetSocketAddress
import org.jboss.netty.channel.group.DefaultChannelGroup
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

      @group = DefaultChannelGroup.new
      @address = InetSocketAddress.new(host, port)
      @pipeline = Pipeline.new(klass, @group, options, @context, &block)
    end

    def start(threadpool)
      @factory = NioServerSocketChannelFactory.new(threadpool, threadpool)
      @bootstrap = ServerBootstrap.new(@factory)
      @bootstrap.setPipelineFactory(@pipeline)
      @bootstrap.setOption("child.tcpNoDelay", true)
      @bootstrap.setOption("child.keepAlive", true)
      @server_channel = @bootstrap.bind(@address)
      @group.add(@server_channel)
    end

    def connection_count
      @group.size - 1 # -1 to exclude the server's channel
    end

    def stop
      @group.close.awaitUninterruptibly
    end
  end
  
end
