import java.util.concurrent.FutureTask

module Foxbat

  class Future < FutureTask

    def initialize(op, cb)
      super(op)
      @callback = cb
    end

    def done
      @callback.call(self.get)
    end
    
  end

end
