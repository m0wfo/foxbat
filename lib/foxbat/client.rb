import org.jboss.netty.channel.socket.nio.NioClientSocketChannelFactory
import org.jboss.netty.bootstrap.ClientBootstrap
require_relative 'generic_connection'

module Foxbat

  class Client < GenericConnection

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
