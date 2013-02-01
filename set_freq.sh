#!/bin/sh
NUMPROCS=$(grep -c ^processor /proc/cpuinfo)
CPUFREQPREFIX=/sys/devices/system/cpu
SAVEPREFIX=/tmp/set_freq/previous_
if [ $# != 1 ]
then
  echo "Usage: $0 <frequency in kHz>"
  echo "       $0 reset"
  exit 1
fi

if [ $1 = "reset" ]
then
  for i in $(seq 0 $(expr $NUMPROCS - 1))
  do
    sudo cp ${SAVEPREFIX}_governor_$i $CPUFREQPREFIX/cpu$i/cpufreq/scaling_governor
    sudo cp ${SAVEPREFIX}_min_$i $CPUFREQPREFIX/cpu$i/cpufreq/scaling_min_freq
    sudo cp ${SAVEPREFIX}_max_$i $CPUFREQPREFIX/cpu$i/cpufreq/scaling_max_freq
  done
  echo "Reset all cores to previous frequency setting"
  exit 0
fi

for freq in $(cat $CPUFREQPREFIX/cpu0/cpufreq/scaling_available_frequencies)
do
  if [ $1 = $freq ]
  then
    for i in $(seq 0 $(expr $NUMPROCS - 1))
    do
      cp $CPUFREQPREFIX/cpu$i/cpufreq/scaling_governor ${SAVEPREFIX}_governor_$i
      cp $CPUFREQPREFIX/cpu$i/cpufreq/scaling_min_freq ${SAVEPREFIX}_min_$i
      cp $CPUFREQPREFIX/cpu$i/cpufreq/scaling_max_freq ${SAVEPREFIX}_max_$i
      echo "userspace" | sudo tee $CPUFREQPREFIX/cpu$i/cpufreq/scaling_governor >/dev/null
      echo "$1" | sudo tee $CPUFREQPREFIX/cpu$i/cpufreq/scaling_setspeed >/dev/null
    done
    echo "Set all cores to $1 kHz, stored previous settings in ${SAVEPREFIX}_*"
    exit 0
  fi
done
echo "Failure: '$1' is not one of the allowed frequencies: $(cat $CPUFREQPREFIX/cpu0/cpufreq/scaling_available_frequencies)"
exit 1
