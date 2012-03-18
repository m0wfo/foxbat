require 'timeout'

module Foxbat

  class FBPhaser < java.util.concurrent.Phaser

    attr_writer :limit, :callback
    
    def onAdvance(phase, parties)
      if (phase + 1) == @limit
        true
      else
        @callback.call if @callback
        false
      end
    end
  end

  class Barrier

    def initialize(tasks, callback=nil, repeat=1, timeout=Long::MAX_VALUE, err=nil)
      @phaser = FBPhaser.new(1)
      if repeat == 0
        repeat = java.lang.Integer::MAX_VALUE
      end
      @phaser.limit = repeat
      @phaser.callback = callback

      phased_tasks = tasks.map do |t|
        Proc.new do
          @phaser.register
          while !@phaser.isTerminated
            begin
              Timeout::timeout(timeout) { t.call }
            rescue Exception => e
              err.call(e) if err
              break
            end
            @phaser.arriveAndAwaitAdvance
          end
        end
      end

      phased_tasks.each { |t| EM.executor.execute(t) }

      start = Proc.new do
        parties = @phaser.getRegisteredParties
        if parties > 1
          @phaser.arriveAndDeregister
        else
          java.lang.Thread.sleep(10)
          start.call
        end
      end

      start.call
    end

    def cancel
      @phaser.forceTermination()
    end

  end
end
