import java.nio.channels.CompletionHandler

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

    def failed(x,y)
      if @on_fail.nil?
        p 'failed'
      else
        @on_fail.call(x,y)
      end
    end

  end

end
