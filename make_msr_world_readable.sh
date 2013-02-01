#!/bin/sh
NUMPROCS=$(grep -c ^processor /proc/cpuinfo)
for i in $(seq 0 $(expr $NUMPROCS - 1))
do
  sudo chmod 0644 /dev/cpu/$i/msr
done 
