module Foxbat

  class Handler
    include CompletionHandler

    def initialize(source, &block)
      @source = source
      @completion = block
    end

    def completed(socket,attachment)
      @completion.call(@source,socket)
    end

    def failed(x,y)
      p 'failed'
    end

  end

end
