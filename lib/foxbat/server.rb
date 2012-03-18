import java.net.InetSocketAddress
import java.nio.channels.AsynchronousServerSocketChannel
import java.nio.channels.AsynchronousSocketChannel
import java.nio.channels.AsynchronousChannelGroup
import java.util.concurrent.TimeUnit
import java.lang.Long
import java.io.IOException

module Foxbat

  class Server

    def create_ssl_engine(connection)
      engine = @ssl_context.createSSLEngine
      engine.setUseClientMode(false)
      engine.setNeedClientAuth(false)
      connection.ssl_engine = engine
    end

    def initialize(host, port, klass, options, block=nil)
      @bind_address = InetSocketAddress.new(host, port)
      @klass = klass
      @block = block || Proc.new {}
    end

    def start(threadpool)
      @group = AsynchronousChannelGroup.withCachedThreadPool(threadpool, 1)
      @server = AsynchronousServerSocketChannel.open(@group)
      @server.bind(@bind_address)

      handler = Foxbat::Handler.new(@server) do |source,socket|
        source.accept(nil,handler)

        connection = @klass.new({})
        connection.channel = socket
        connection.block = @block
        connection.server_post_init
        connection.post_init

        connection.read_channel
      end

      @server.accept(nil, handler)

      
    end

    def stop
      @server.close
      @group.awaitTermination(0, TimeUnit::SECONDS)
    end
  end
  
end
