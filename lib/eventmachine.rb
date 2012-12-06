import java.lang.Long
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import org.jboss.netty.util.HashedWheelTimer

require 'foxbat/future'

module EventMachine

  def self.start_server(host, port=nil, handler=nil, *args, &block)
    s = Foxbat::Server.new(host, port, handler, args.first || {}, &block)

    @@servers ||= []
    @@servers << s

    s.start(@@threadpool)
  end

  def self.connect(host, port=nil, handler=nil, *args, &block)
    c = Foxbat::Client.new(host, port, handler, args.first ||  {}, &block)
    c.start(@@threadpool)
  end

  # We're on the JVM- this does nothing!
  def self.epoll; end
  def self.kqueue; end

  def self.run(blk=nil, tail=nil, &block)
    @alive = true
    @@threadpool = Executors.newCachedThreadPool
    @@timer = HashedWheelTimer.new

    block.call

    @@threadpool.awaitTermination(Long::MAX_VALUE, TimeUnit::SECONDS)
  end

  def self.add_timer(*args, &block)
    timeout = args.shift
    callable = args.shift || block
    task = lambda { |t| callable.call }
    @@timer.newTimeout(task, timeout, TimeUnit::SECONDS)
  end

  def self.stop
    @@servers.each { |s| s.stop }
    @@threadpool.shutdown
    @@timer.stop
  end

  def self.defer(op, callback)
    task = Foxbat::Future.new(op, callback)
    @@threadpool.submit(task)
  end

  def self.reactor_running?
    @alive
  end

  def self.connection_count
    @@servers.map { |s| s.connection_count }.reduce(:+)
  end

end

