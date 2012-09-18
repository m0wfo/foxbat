import java.lang.Long
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

module EventMachine

  def self.start_server host, port=nil, handler=nil, *args, &block
    s = Foxbat::Server.new(host, port, handler, args.first || {}, &block)

    @@servers ||= []
    @@servers << s

    s.start(@@threadpool)
  end

  # We're on the JVM- this does nothing!
  def self.epoll; end
  def self.kqueue; end

  def self.run(blk=nil, tail=nil, &block)
    @@threadpool = Executors.newCachedThreadPool

    block.call

    @@threadpool.awaitTermination(Long::MAX_VALUE, TimeUnit::SECONDS)
  end

  def self.stop
    @@servers.each { |s| s.stop }
    @@threadpool.shutdownNow
  end

  def self.executor
    @@threadpool
  end

end

