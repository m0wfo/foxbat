import java.net.InetSocketAddress
import org.jboss.netty.channel.group.DefaultChannelGroup
require_relative 'pipeline'
require_relative 'security'

module Foxbat

  class GenericConnection

    def initialize(host, port, klass, options, &block)
      if options[:secure]
        @context = Security.setup_ssl_context(options[:keystore])
      end

      @group = DefaultChannelGroup.new
      @address = InetSocketAddress.new(host, port)
      @pipeline = Pipeline.new(klass, @group, false, options, @context, &block)
    end

    def start; end
  end

end
