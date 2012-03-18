# foxbat

A plug-compatible EventMachine replacement, built from the ground up for JRuby and Java 7.

## tl;dr

Java 7 is cool (really!): proper native asynchronous I/O, phasers etc. The JRuby port of EventMachine doesn't do TLS. And then there was Foxbat.

## What works

* TCP Server, aka EM::start_server
* Timers (one-shot and periodic)
* ...watch this space

## Cool stuff you don't get with plain-old eventmachine

* The EM run-loop is actually backed by a cached thread pool
* Mutually exclusive timers / futures for fine-grained thread coordination
* Easy to use barriers
* Written in pure Ruby- no native code (although it *is* tied to the JVM)
* ...watch this space

## Getting started

Get the gem:

    jgem install foxbat

Require it (before eventmachine!):

    require 'foxbat'
