#!/bin/bash

if [ $# -eq 1 ]; then
	jobname="$1"
else
	jobname="."
fi

JOBTYPES=$(echo "list jobtotals" | bconsole | grep -e '^|' | sed -e 's/|/\t/g' | sed 1d | awk ' { print $4 } ' | grep -v -e '^$' | grep -e "^$jobname")
NOW=$(date +%s)
WARN=$((2*86400))
CRIT=$((7*86400))
LEVEL=0
for job in $JOBTYPES; do
	LASTRUN=$(echo 'list job='$job | bconsole | grep -e '^|' | sed 1d | grep '| T ' | sed -e 's/|/\t/g' | tail -n 1 | awk ' { print $3" "$4 } ')
	LASTRUN_UNIX=$(date --date="${LASTRUN}" "+%s")
	if [ "$(($NOW - $LASTRUN_UNIX))" -gt "$WARN" ]; then
		if [ "$((${NOW}-${LASTRUN_UNIX}))" -gt "$CRIT" ]; then
			echo "Critical: job ${job} last ran successfully $((${NOW}-${LASTRUN_UNIX})) seconds ago"
			LEVEL=2
		else
			echo "Warning: job ${job} last ran successfully $((${NOW}-${LASTRUN_UNIX})) seconds ago"
			if [ $LEVEL -eq 0 ]; then
				LEVEL=1
			fi
		fi
	fi
done

if [ $LEVEL -eq 0 ]; then
	echo "All jobs ran successfully within $WARN seconds."
fi

exit $LEVEL
