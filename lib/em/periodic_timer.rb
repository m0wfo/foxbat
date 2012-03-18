module EventMachine

  class PeriodicTimer

    def initialize(interval, callback=nil, repeat=0, &block)
      work = callback || block
      t = lambda { sleep interval; work.call }
      @timer = Foxbat::Barrier.new([t], repeat)
    end

    def cancel
      @timer.cancel
    end

  end

end
