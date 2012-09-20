import org.jboss.netty.channel.socket.nio.NioServerSocketChannelFactory
import org.jboss.netty.bootstrap.ServerBootstrap
require_relative 'generic_connection'

module Foxbat

  class Server < GenericConnection
    def start(threadpool)
      factory = NioServerSocketChannelFactory.new(threadpool, threadpool)
      @bootstrap = ServerBootstrap.new(factory)
      @bootstrap.setPipelineFactory(@pipeline)
      @bootstrap.setOption("child.tcpNoDelay", true)
      @bootstrap.setOption("child.keepAlive", true)
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
