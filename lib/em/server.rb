import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.nio.channels.AsynchronousServerSocketChannel
import java.nio.channels.AsynchronousSocketChannel
import java.nio.channels.AsynchronousChannelGroup
import java.nio.charset.Charset
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.lang.Long

import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManagerFactory
import java.security.KeyStore

#require File.join(File.dirname(__FILE__), 'handler.rb')

module EventMachine

  class Server

    BUF_SIZE = 128

    def initialize(host, port, klass, block)
      @bind_address = InetSocketAddress.new(host, port)
      @service = Executors.newCachedThreadPool(Executors.defaultThreadFactory)
      @group = AsynchronousChannelGroup.withCachedThreadPool(@service, 1)
      @server = AsynchronousServerSocketChannel.open(@group)
      @klass = klass
      @block = block
      @charset = Charset.forName("UTF-8")
    end

    def start
      @server.bind(@bind_address)

      handler = Foxbat::Handler.new(@server) do |source,socket|
        source.accept(nil,handler)

        connection = @klass.new({:debug => true})
        connection.channel = socket
        connection.post_init                      

        read_channel(socket, connection)
      end

      @server.accept(nil, handler)

      @service.awaitTermination(Long::MAX_VALUE, TimeUnit::SECONDS)
    end

    def read_channel(channel, connection, buffer=nil, memo="")
      @block.call(connection)

      if buffer.nil?
        bb = ByteBuffer.allocate(BUF_SIZE)
        bb.clear

        return read_channel(channel, connection, bb)
      end

      reader = Foxbat::Handler.new(channel) do |c,br|

        if br == -1
          c.close
          connection.unbind
        else
          buffer.flip
          str = btos(buffer)
          memo << str
          buffer.clear

          if br == BUF_SIZE
            buffer.rewind
            read_channel(c, connection, buffer, memo)
          else
            p memo
            connection.receive_data(memo)
            read_channel(c, connection)
          end

        end
      end

      channel.read(buffer, nil, reader)
    end

    def stop
      @server.close
      @group.awaitTermination(1, TimeUnit::SECONDS)
      @service.shutdownNow
    end
    
    def btos(buf)
      @charset.decode(buf).toString
    end
  end
  
end
