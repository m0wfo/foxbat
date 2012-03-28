module Foxbat

  class ServerFactory

    def self.setup(*args)
      klass = Server
      klass = SecureServer if options[:secure]
      klass.send(:new, args)
    end
    
  end

end
