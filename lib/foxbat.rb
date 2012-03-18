require 'java'

require 'em/connection'
require 'foxbat/barrier'
require 'foxbat/server'
require 'foxbat/handler'
require 'foxbat/version'
require File.join(File.dirname(__FILE__), 'eventmachine.rb')

module EventMachine; end
EM = EventMachine
