#!/bin/sh
NUMPROCS=$(grep -c ^processor /proc/cpuinfo)
CPUFREQPREFIX=/sys/devices/system/cpu
SAVEDIR=/tmp/set_freq
SAVEPREFIX=$SAVEDIR/previous
SAVE=1

while getopts s:rn o
do	case "$o" in
	s)	if [ "$OP" = "reset" ]
                then
                  echo "Error: Cannot specify -s and -r" >&2
                  exit 1
                fi
                OP="set"
                FREQ="$OPTARG";;
	r)	if [ "$OP" = "set" ]
                then
                  echo "Error: Cannot specify -s and -r" >&2
                  exit 1
                fi
                OP="reset";;
        n)      SAVE=0;;
	[?])	echo "Usage: $0 [-s freq_in_khz] [-n] [-r]" >&2
		exit 1;;
	esac
done

if [ -z $OP ]
then
  echo "Usage: $0 [-s freq_in_khz] [-n] [-r]" >&2
  exit 1
fi

# Reset $@
shift `echo $OPTIND-1 | bc`

if [ $OP = "reset" ]
then
  for i in $(seq 0 $(expr $NUMPROCS - 1))
  do
    sudo cp ${SAVEPREFIX}_governor_$i $CPUFREQPREFIX/cpu$i/cpufreq/scaling_governor
    sudo cp ${SAVEPREFIX}_min_$i $CPUFREQPREFIX/cpu$i/cpufreq/scaling_min_freq
    sudo cp ${SAVEPREFIX}_max_$i $CPUFREQPREFIX/cpu$i/cpufreq/scaling_max_freq
  done
  echo "Reset all $NUMPROCS cores to previous frequency setting"
  exit 0
fi

mkdir -p $SAVEDIR
for freq2 in $(cat $CPUFREQPREFIX/cpu0/cpufreq/scaling_available_frequencies)
do
  if [ $FREQ = $freq2 ]
  then
    for i in $(seq 0 $(expr $NUMPROCS - 1))
    do
      if [ $SAVE = 1 ]
      then
        cp $CPUFREQPREFIX/cpu$i/cpufreq/scaling_governor ${SAVEPREFIX}_governor_$i
        cp $CPUFREQPREFIX/cpu$i/cpufreq/scaling_min_freq ${SAVEPREFIX}_min_$i
        cp $CPUFREQPREFIX/cpu$i/cpufreq/scaling_max_freq ${SAVEPREFIX}_max_$i
      fi
      echo "userspace" | sudo tee $CPUFREQPREFIX/cpu$i/cpufreq/scaling_governor >/dev/null
      echo "$FREQ" | sudo tee $CPUFREQPREFIX/cpu$i/cpufreq/scaling_setspeed >/dev/null
    done
    echo -n "Set all $NUMPROCS cores to $FREQ kHz, "
    if [ $SAVE = 1 ]
    then
      echo "stored previous settings in ${SAVEPREFIX}_*"
    else
      echo "did not save previous settings"
    fi
    exit 0
  fi
done
echo "Failure: '$FREQ' is not one of the allowed frequencies: $(cat $CPUFREQPREFIX/cpu0/cpufreq/scaling_available_frequencies)"
exit 1
