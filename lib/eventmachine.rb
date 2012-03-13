require 'java'

require 'em/connection'
#require 'em/server'

module EventMachine

  def self.start_server server, port=nil, handler=nil, *args, &block
    p 'starting :)'
    p 'now what, foo?'
  end

  # We're on Java, this does nothing!
  def self.epoll; end

  def self.run(blk=nil, tail=nil, &block)
    block.call
  end

  def self.stop
    p 'stopping...'
  end

end

# Alias for {EventMachine}
EM = EventMachine
