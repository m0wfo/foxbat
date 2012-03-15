import java.net.InetSocketAddress
import java.nio.channels.AsynchronousServerSocketChannel
import java.nio.channels.AsynchronousSocketChannel
import java.nio.channels.AsynchronousChannelGroup
import java.util.concurrent.Executors
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

    def initialize(host, port, klass, block)
      @bind_address = InetSocketAddress.new(host, port)
      @service = Executors.newCachedThreadPool(Executors.defaultThreadFactory)
      @group = AsynchronousChannelGroup.withCachedThreadPool(@service, 1)
      @server = AsynchronousServerSocketChannel.open(@group)
      @klass = klass
      @block = block

      setup_ssl
    end

    def start
      @server.bind(@bind_address)

      handler = Foxbat::Handler.new(@server) do |source,socket|
        source.accept(nil,handler)

        connection = @klass.new({:debug => true})
        connection.channel = socket
        connection.block = @block
        connection.executor = @service

        engine = @ssl_context.createSSLEngine
        engine.setUseClientMode(false)
        engine.setNeedClientAuth(false)

        connection.ssl_engine = engine
        connection.post_init

        connection.read_channel
      end

      @server.accept(nil, handler)

      @service.awaitTermination(Long::MAX_VALUE, TimeUnit::SECONDS)
    end

    def stop
      @server.close
      @group.awaitTermination(1, TimeUnit::SECONDS)
      @service.shutdownNow
    end
  end
  
end
