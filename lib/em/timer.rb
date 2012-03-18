module EventMachine

  class Timer

    def initialize(interval, callback=nil, &block)
      PeriodicTimer.new(interval, callback, 1, &block)
    end

    def cancel
      @timer.cancel
    end

  end

end
