module EventMachine

  def self.start_server host, port=nil, handler=nil, *args, &block
    s = Foxbat::Server.new(host, port, handler, block)

    @@servers ||= []
    @@servers << s

    s.start
  end

  # We're on the JVM- this does nothing!
  def self.epoll; end

  def self.run(blk=nil, tail=nil, &block)
    block.call
  end

  def self.stop
    @@servers.each { |s| s.stop }
  end

end

