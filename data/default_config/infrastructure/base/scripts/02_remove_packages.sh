#!/bin/sh

dpkg --list | grep ^rc | awk '{print $2}' | xargs dpkg --purge
apt-get purge portmap
apt-get autoremove
