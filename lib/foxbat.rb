require 'java'

require 'em/connection'
require 'em/periodic_timer'
require 'em/timer'
require 'foxbat/barrier'
require 'foxbat/secure_server'
require 'foxbat/server'
require 'foxbat/handler'
require 'foxbat/version'
require File.join(File.dirname(__FILE__), 'eventmachine.rb')

module EventMachine; end
EM = EventMachine
