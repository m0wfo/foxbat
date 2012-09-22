B1;3202;0c# foxbat

A plug-compatible EventMachine replacement, based on [netty](http://netty.io/).

## tl;dr

This project aims to be a performant and full-featured EM replacement for JRuby apps.

## What works

* TCP Server, aka EM.start_server
* TCP Client, aka EM.connect
* SSL
* EM.defer
* One-shot timers


## Getting started

Get the gem:

    jgem install foxbat

Require it:

    require 'foxbat'
