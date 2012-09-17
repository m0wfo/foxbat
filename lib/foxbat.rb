require 'java'
require 'netty-3.5.0.Final.jar'

require 'em/connection'
require 'em/periodic_timer'
require 'em/timer'
require 'foxbat/server'
require 'foxbat/version'
require_relative 'eventmachine'

module EventMachine; end
EM = EventMachine
