import java.util.concurrent.Phaser

module Foxbat

  class Phaser
    def onAdvance(x,y)
      p x
    end
  end

  class Barrier

    def initialize(tasks, repeat=1)
      @phaser = Phaser.new(1)
      if repeat == :infinite
        repeat = java.lang.Integer::MAX_VALUE
      end
      @running = AtomicBoolean.new(true)

      phased_tasks = tasks.map do |t|
        Proc.new do
          @phaser.register
          while !@phaser.isTerminated && @phaser.getPhase <= repeat-1
            t.call
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
