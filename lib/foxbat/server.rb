import java.net.InetSocketAddress
import java.nio.channels.AsynchronousServerSocketChannel
import java.nio.channels.AsynchronousSocketChannel
import java.nio.channels.AsynchronousChannelGroup
import java.util.concurrent.TimeUnit
import java.lang.Long
import java.io.IOException

# SSL stuff
import javax.net.ssl.SSLContext
import javax.net.ssl.KeyManagerFactory
import javax.net.ssl.TrustManagerFactory
import javax.net.ssl.SSLEngineResult
import java.security.KeyStore
import java.io.FileInputStream

module Foxbat

  class Server

    def setup_keystore(path)
      keystore = KeyStore.getInstance(KeyStore.getDefaultType)
      fis = FileInputStream.new(path)
      
      p 'Enter passphrase for keystore:'
      password = java.lang.System.console.readPassword()

      begin
        keystore.load(fis, password)
      rescue IOException
        p 'Invalid passphrase.'
        fis.close
        setup_keystore(path)
      end
      fis.close

      kmf = KeyManagerFactory.getInstance('SunX509')
      tmf = TrustManagerFactory.getInstance('SunX509')

      kmf.init(keystore, password)
      tmf.init(keystore)

      password = nil # Paranoid, per the JavaDoc
      [kmf, tmf]
    end

    def setup_ssl(keystore_path)
      @secure = true
      @ssl_context = SSLContext.getInstance('TLSv1')
      kmf, tmf = setup_keystore(keystore_path)
      @ssl_context.init(kmf.getKeyManagers, tmf.getTrustManagers, nil)
    end

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
      @secure = options[:secure] || false

      setup_ssl(options[:keystore]) if @secure
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


        create_ssl_engine(connection) if @secure
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
