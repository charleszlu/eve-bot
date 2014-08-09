#!/bin/sh

# Kill any existing eve-bots
#sudo kill $(pgrep eve-bot.py | awk '{print $1}')
pkill -x eve-bot.py

# The script calls python2 instead of python, so need to do a symlink
#sudo ln -s /usr/bin/python /usr/bin/python2

# Set up the protobuf plugin for python
#cd ${0%/*}/protobuf/python &&
#python ./setup.py install
#cd ../..

# Wait for the Murmur server to come on-line and run the python script
PROCESS="murmurd"
#PROCANDARGS=$*
a=0

while [ $a -lt 10 ]
do
    RESULT=`pgrep ${PROCESS}`

    if [ "${RESULT:-null}" = null ]; then
            #echo "${PROCESS} not running, starting "$PROCANDARGS
            #$PROCANDARGS &
			echo "Murmur server not running, waiting..."
			logger "Murmur server not running, waiting..."
    else
    	    echo "Waiting for 2 seconds..."
    	    sleep 2
            echo "Murmur server running, starting eve-bot..."
			logger "Murmur server running, starting eve-bot..."
			nohup ${0%/*}/eve-bot.py -e "BBU" -r "BBU Spectator (with delay)" -s localhost -p 64738 -d 105 -n "BBUBot" -m "Delayed-" > /dev/null 2>&1 &
			sleep 2
			nohup ${0%/*}/eve-bot.py -e "Pei Pei and Friends" -r "Pei Pei Spectator (with delay)" -s localhost -p 64738 -d 105 -n "PeiPeiBot" -m "Delay-" > /dev/null 2>&1 &
			break
    fi
	
	# Do max of 10 loops  before failing
	if [ $a = 9 ]; then
		echo "Murmur failed to start, exiting script..."
		logger "Murmur failed to start, exiting script..."
	fi
	
	a=`expr $a + 1`
    sleep 1
done    


# Return to the home directory
cd ~
