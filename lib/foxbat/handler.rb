import java.nio.channels.CompletionHandler
import java.nio.channels.AsynchronousCloseException

module Foxbat

  class Handler
    include CompletionHandler

    attr_writer :on_fail

    def initialize(source, &block)
      @source = source
      @completion = block
    end

    def completed(socket,attachment)
      @completion.call(@source,socket)
    end

    def failed(err,attachment)
      if !err.is_a?(AsynchronousCloseException)
        if @on_fail.nil?
          p "ERR: #{x.inspect} -> #{y.inspect}"
        else
          @on_fail.call(err, attachment)
        end
      end
    end

  end

end
