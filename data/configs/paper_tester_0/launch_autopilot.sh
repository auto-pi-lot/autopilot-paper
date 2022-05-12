#!/bin/bash
killall jackd
sudo killall pigpiod
sudo mount -o remount,size=128M /dev/shm
source /home/pi/git/autopilot/venv/bin/activate
python3 -m autopilot.core.pilot -f /home/pi/autopilot/prefs.json