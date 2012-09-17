import java.net.InetSocketAddress
import org.jboss.netty.channel.socket.nio.NioServerSocketChannelFactory
import org.jboss.netty.bootstrap.ServerBootstrap
require_relative 'pipeline'

module Foxbat

  class Server

    def initialize(host, port, klass, options, block=nil)
      @address = InetSocketAddress.new(host, port)
      @pipeline = Pipeline.new(klass)
    end

    def start(threadpool)
      @factory = NioServerSocketChannelFactory.new(threadpool, threadpool)
      @bootstrap = ServerBootstrap.new(@factory)
      @bootstrap.setPipelineFactory(@pipeline)
      @bootstrap.bind(@address)
    end

    def stop
    end
  end
  
end
