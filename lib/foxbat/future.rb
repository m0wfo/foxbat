import com.google.common.util.concurrent.ListenableFutureTask

module Foxbat

  class Future

    def self.schedule(op, cb, executor)
      future = ListenableFutureTask.create(op)
      future.addListener(cb, executor)
      executor.submit(future)
    end
    
  end

end
