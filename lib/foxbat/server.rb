import java.net.InetSocketAddress
import java.nio.channels.AsynchronousServerSocketChannel
import java.nio.channels.AsynchronousSocketChannel
import java.nio.channels.AsynchronousChannelGroup
import java.util.concurrent.TimeUnit
import java.lang.Long

# SSL stuff
import javax.net.ssl.SSLContext
import javax.net.ssl.KeyManagerFactory
import javax.net.ssl.TrustManagerFactory
import javax.net.ssl.SSLEngineResult
import java.security.KeyStore
import java.io.FileInputStream

module Foxbat

  class Server

    def setup_ssl
      @ssl_context = SSLContext.getInstance('TLSv1')
      @keystore = KeyStore.getInstance(KeyStore.getDefaultType)
      fis = FileInputStream.new('/tank/me/.keystore')

      password = 'marsbars'.to_java.toCharArray
      @keystore.load(fis, password)
      fis.close

      @kmf = KeyManagerFactory.getInstance('SunX509')
      @tmf = TrustManagerFactory.getInstance('SunX509')

      @kmf.init(@keystore, password)
      @tmf.init(@keystore)

      @ssl_context.init(@kmf.getKeyManagers, @tmf.getTrustManagers, nil)
    end

    def initialize(host, port, klass, block=nil)
      @bind_address = InetSocketAddress.new(host, port)
      @klass = klass
      @block = block || Proc.new {}

#      setup_ssl
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
        connection.executor = @service

#        engine = @ssl_context.createSSLEngine
#        engine.setUseClientMode(false)
#        engine.setNeedClientAuth(false)

#        connection.ssl_engine = engine
        connection.post_init
        connection.set_time

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
