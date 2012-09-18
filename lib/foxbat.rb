require 'java'

NETTY_VERSION = '3.5.0.Final'
JAR_SIZE = 1110903.0 # TODO: remove hard-coded jar size

netty_jar = File.dirname(__FILE__) + "/netty-#{NETTY_VERSION}.jar"

if !File.exist?(netty_jar)
  puts "Couldn't find netty's JAR to load. Let's download it now."
  
  require 'net/http'
  f = open(netty_jar, 'w')

  Net::HTTP.start('search.maven.org') do |http|

    begin
    http.request_get("/remotecontent?filepath=io/netty/netty/#{NETTY_VERSION}/netty-#{NETTY_VERSION}.jar") do |resp|
    acc = 0
    resp.read_body do |segment|
          acc += segment.length
          percent = ((acc / JAR_SIZE) * 100).to_i
          print "Downloading netty #{NETTY_VERSION} from maven repository... [#{percent}%]\r"
          f.write(segment)
        end
        puts "\nDone. You shouldn't see me again :)"
      end
  ensure
    f.close()
    end
  end
end

require 'netty-3.5.0.Final.jar'

require 'em/connection'
require 'em/periodic_timer'
require 'em/timer'
require 'foxbat/server'
require 'foxbat/version'
require_relative 'eventmachine'



module EventMachine; end

begin
  Kernel.const_get(:EM)
rescue
  EM = EventMachine
end

