#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com
# August 26, 2015

source utils.sh

# TODO - need to add script to kill -9 all existing java processes to prevent port conflicts

echo "***********************************************************************"
echo "Begin '$BASH_SOURCE' script..."
date
echo "***********************************************************************"
echo "JAVA_HOME=$JAVA_HOME"
echo "PATH=$PATH"
echo `java -version`
echo "------- Test run: `uname -a`" >> $RESULTS_FILE
echo "------- Start of test run: `date`" >> $RESULTS_FILE

for RUNTIME in $LIST_OF_SERVERS
	do
		for TASK in $LIST_OF_TASKS
		do
			for i in `seq 1 $REPEATS`;
   				do
        			./one.sh $RUNTIME $TASK
        			if [ $? != 0 ]; then
        				ERROR="!!!!!!!!!! Error while running the test $TASK for $RUNTIME"
        				echo $ERROR
						echo $ERROR >> $RESULTS_FILE
						exit 1
					fi
   		done  
	done
done
echo "------- End of test run: `date`" >> $RESULTS_FILE
echo "***********************************************************************"
echo "The '$BASH_SOURCE' script is done. See you next time."
echo "***********************************************************************"