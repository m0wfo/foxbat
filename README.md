# foxbat

A plug-compatible EventMachine replacement, built from the ground up for JRuby and Java 7.

## tl;dr

Java 7 is cool (really!): proper native asynchronous I/O, phasers etc. The JRuby port of EventMachine doesn't do TLS. And then there was Foxbat.

## Getting started

Get the gem:

    jgem install foxbat

Require it (before eventmachine!):

    require 'foxbat'
