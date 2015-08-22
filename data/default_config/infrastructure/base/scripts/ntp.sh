#!/bin/sh


### NTP ###

# We are running NTP to keep the clock accurate.


## Installation

sudo apt-get install ntp ntp-doc ntpdate


## Configuration

# We are using the default configuration that Debian ships with. This is primarily a client configuration – we allow other systems only to get the current time; they may not query any further information. (This is limited via the restrict keyword.) The daemon runs primarily in order to sync the system's time with the upstream NTP servers.

# The configuration file points to multiple upstream NTP servers within debian.pool.ntp.org.


## TODO

# Need to test that NTP is working.
