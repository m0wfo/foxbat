require 'java'

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

def require_or_get(lib, version, ns)
  jar = "#{lib}-#{version}.jar"
  jarpath = File.dirname(__FILE__) + '/' + jar
  if !File.exist?(jarpath)
    puts "Couldn't find #{lib}, let's download it now."
  
    require 'net/http'
    f = open(jarpath, 'w')

    Net::HTTP.start('search.maven.org') do |http|

      begin
        http.request_get("/remotecontent?filepath=#{ns}/#{lib}/#{version}/#{jar}") do |resp|
          puts "Downloading #{jar} from maven repository..."
          resp.read_body do |segment|
            f.write(segment)
          end
          puts "Done."
        end
      ensure
        f.close()
      end
    end
  end

  require jar
end

require_or_get 'netty', '3.5.0.Final', 'io/netty'
require_or_get 'guava', '13.0.1', 'com/google/guava'

require 'em/connection'
require 'em/deferrable'
require 'em/periodic_timer'
require 'em/timer'
require 'foxbat/client'
require 'foxbat/server'
require 'foxbat/version'

require_relative 'eventmachine'

module EventMachine; end

begin
  Kernel.const_get(:EM)
rescue
  EM = EventMachine
end

