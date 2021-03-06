# foxbat

A plug-compatible EventMachine replacement, based on [netty](http://netty.io/).

## tl;dr

The JRuby port of EventMachine has been neglected for some time. Rather than trying to fix a string of long-standing bugs in an ageing codebase, it makes more sense to use a feature-complete, stable, battle-tested I/O library that's already been developed.

This project aims to be a performant and full-featured EM replacement for JRuby apps.

## What works

* TCP Server, aka EM.start_server
* TCP Client, aka EM.connect
* SSL (now on client + server)
* EM.defer
* One-shot timers
* Zero-copy file transfer


## Getting started

Get the gem:

    jgem install foxbat

Require it:

    require 'foxbat'
