#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com
# August 26, 2015

# ---------------------------- These are possible runtimes to be tested
LIST_OF_SERVERS="liberty glassfish tomcat jetty jboss wildfly tomee weblogic websphere"
#LIST_OF_SERVERS="glassfish tomcat jetty jboss wildfly tomee liberty weblogic websphere"

# ---------------------------- These are possible execution targets (similar to ant targets) 
LIST_OF_TASKS="restartExistingServerWithApp redeployHelloWorld stopWhateverExistingServer"
#LIST_OF_TASKS="startExistingEmptyServer restartExistingServerWithApp redeployHelloWorld redeployJenkins redeployAppInRunningServer startWhateverExistingServer stopWhateverExistingServer"

# ---------------------------- How many times to repeat each test
REPEATS=1

# Results of tests to be written into this file
RESULTS_FILE=$PROJECT_HOME/test_results.txt

# ---------------------------- Application specific variables
SERVER_HOST="http://localhost"

# ---------------------------- Define test apps
JenkinsApp="Jenkins"
HelloWorldApp="HelloWorld"
# Which of the apps to use for default tests
DefaultApp=$HelloWorldApp

# ----------------------------------------------- Wait times in seconds
LONG_SLEEP_TIME=6
SHORT_SLEEP_TIME=3
APP_DEPLOY_TIMEOUT=80
APP_UN_DEPLOY_TIMEOUT=10
MAX_WAIT_NO_MESSAGE=40
MAX_WAIT_NO_LOG=6
LOG_FILE_TIMEOUT=40

###############################################
# Setup app evnironment
# arguments:
# $1 - app name
###############################################
setup_app()
{
	echo "---> setup_app(): argument provided is '$1'"
	if [ "$1" == "$JenkinsApp" ]; then
		echo "Setup Jenkins app..."
		export APP_URL="jenkins"
		export WAR_NAME="jenkins.war"
		export APP_TEST_STRING_old="Welcome to Jenkins"
		# secondary search string and URL are used to test the app in more than just one way
		export APP_TEST_STRING_old_secondary="This is old version of Jenkins app 1.627.old"
		export APP_URL_secondary="jenkins/css/style.css"
		export FULL_SOURCE_WAR_NAME_old=$PROJECT_HOME/applications/jenkins_old/$WAR_NAME
		export APP_TEST_STRING_new="Welcome to Jenkins"
		export APP_TEST_STRING_new_secondary="This is an custom made version of Jenkins for redeployment test 1.627.new"
		export FULL_SOURCE_WAR_NAME_new=$PROJECT_HOME/applications/jenkins_new/$WAR_NAME
		export APP_REDEPLOY_SLEEP=2
		export APP_NAME=$JenkinsApp
	else
		echo "By default we will setup HelloWorld app..."
		export APP_URL="HelloWorld/HelloServlet"
		export APP_URL_secondary=$APP_URL
		export WAR_NAME="HelloWorld.war"
		# HelloWorld test servlet - old version (need to test re-deployment)
		export APP_TEST_STRING_old="The servlet name: com.test.HelloServlet v.1.13"
		export APP_TEST_STRING_old_secondary="Servlet info"
		export FULL_SOURCE_WAR_NAME_old=$PROJECT_HOME/applications/HelloWorld.v1.13/$WAR_NAME
		# HelloWorld test servlet - new version (need to test re-deployment)
		export APP_TEST_STRING_new="The servlet name: com.test.HelloServlet v.1.14"
		export APP_TEST_STRING_new_secondary="Servlet info"
		export FULL_SOURCE_WAR_NAME_new=$PROJECT_HOME/applications/HelloWorld.v1.14/$WAR_NAME
		export APP_REDEPLOY_SLEEP=0
		export APP_NAME=$HelloWorldApp
	fi

	UNDEPLOY_WAR=$DEPLOY_DIR/$WAR_NAME
	echo "<--- setup_app(): UNDEPLOY_WAR='$UNDEPLOY_WAR'"
}

###############################################
# Starts measurements of time
###############################################
start_timer()
{
	echo "--->start_timer()"
	START_TIME=`date +%s.%N`
}

###############################################
# Stop timer and write data into the log file
###############################################
stop_timer()
{
	END_TIME=`date +%s.%N`
#	MEASURED_TIME=`expr $END_TIME - $START_TIME`
	MEASURED_TIME=`echo "$END_TIME - $START_TIME" | bc`
	echo "<---stop_timer(): MEASURED_TIME='$MEASURED_TIME' seconds"
}

###############################################
# Short sleep
###############################################
short_sleep()
{
	echo "Waiting (short) for $SHORT_SLEEP_TIME sec to let the CPU calm down..."
	sleep $SHORT_SLEEP_TIME
}

###############################################
# Long sleep
###############################################
long_sleep()
{
	echo "Waiting (long) for $LONG_SLEEP_TIME sec to let the CPU calm down..."
	sleep $LONG_SLEEP_TIME
}

###############################################
# Start server - also checks for proper log output that server is started
###############################################
start_server()
{
	echo "--->start_server(): RUNTIME='$RUNTIME'"
	remove_log_file
    $START_COMMAND
    if [ $? != 0 ]; then
    	echo "!!!!!! ERROR while running command: '$START_COMMAND'"
    	exit 1
	fi
	STATUS=0
	COUNT=0
	while [ $STATUS = 0 ]
	do
		# grep returns code 0 if string was found at least once
		grep -c "$START_MESSAGE" $STD_OUT_FILE
		RC=$?
		# 0 means found, 1 not found, 2 - file does not exist
		if [ $RC = 0 ]; then
			# finish this task
			STATUS=1
		else
			# since correct string is not found, need to wait a little more for server to start
			if [[ $COUNT -gt $MAX_WAIT_NO_MESSAGE ]]; then
				echo "!!!!!! ERROR We have waited long enough $MAX_WAIT_NO_MESSAGE - and still there is no message or no file, this means the '$RUNTIME' server will never start"
				exit 1
			else
				sleep 1
				(( COUNT++ ))
				echo "    Waiting $COUNT seconds for '$RUNTIME' server to start..."
			fi
		fi
	done
	echo "<---start_server()"
}

###############################################
# Stop server
###############################################
stop_server()
{
	echo "--->stop_server(): RUNTIME='$RUNTIME'"
	$STOP_COMMAND
    if [ $? != 0 ]; then
    	echo "Error here is normal because the '$RUNTIME' server may already be stopped"
	fi
	STATUS=0
	COUNT=0
	while [ $STATUS = 0 ]
	do
		# grep returns code 0 if string was found at least once
		grep -c "$STOP_MESSAGE" $STOP_LOG_FILE
		RC=$?
		# return = 0 means found, 1 not found, 2 - file does not exist
		if [ $RC == 0 ]; then
			# finish this task
			STATUS=1
		else
			# since correct string is not found, need to wait a little more for server to start
			if [[ $RC == 2 && $COUNT -gt $MAX_WAIT_NO_LOG ]]; then
				echo "    We have waited long enough $MAX_WAIT_NO_LOG sec - and still there is no file, this means the '$RUNTIME' server is stopped already"
				STATUS=1
			elif [[ $RC == 1 && $COUNT -gt $MAX_WAIT_NO_MESSAGE ]]; then
				echo "    We have waited long enough $MAX_WAIT_NO_MESSAGE sec - and still there is no message in existing log file, this means the '$RUNTIME' server is stopped already"
				STATUS=1
			else
				sleep 1
				(( COUNT++ ))
				echo "    Waiting $COUNT seconds for '$RUNTIME' server to stop..."
			fi
		fi
	done
	echo "<---stop_server()"
}

###############################################
# deploy new version of the application
###############################################
deploy_new_app()
{
	echo "--->deploy_new_app()"
	APP_TEST_STRING=$APP_TEST_STRING_new
	APP_TEST_STRING_secondary=$APP_TEST_STRING_new_secondary
	FULL_SOURCE_WAR_NAME=$FULL_SOURCE_WAR_NAME_new
	deploy_app
	echo "<---deploy_new_app()"
}

###############################################
# deploy old version of the application
###############################################
deploy_old_app()
{
	echo "--->deploy_old_app()"
	APP_TEST_STRING=$APP_TEST_STRING_old
	APP_TEST_STRING_secondary=$APP_TEST_STRING_old_secondary
	FULL_SOURCE_WAR_NAME=$FULL_SOURCE_WAR_NAME_old
	deploy_app
	echo "<---deploy_old_app()"
}

###############################################
# Deploy application
###############################################
deploy_app()
{
	echo "--->deploy_app(): '$FULL_SOURCE_WAR_NAME' into '$UNDEPLOY_WAR'"
	# Now is the time to do pre-deploy specific commands
#	${RUNTIME}_${APP_NAME}_predeploy

#	cp --preserve=timestamps $FULL_SOURCE_WAR_NAME $UNDEPLOY_WAR
	cp $FULL_SOURCE_WAR_NAME $UNDEPLOY_WAR
	if [ $? != 0 ]; then
		echo "!!!!!!!!!!!! Error while copying war file '$FULL_SOURCE_WAR_NAME' to the deploy war '$UNDEPLOY_WAR'"
		exit 1
	fi

	# Check that the new file is the one we want
#	SOURCE_FILE_DATE=`stat -c %y $FULL_SOURCE_WAR_NAME | awk '{printf $1 "\n"}'`
#	DEST_FILE_DATE=`stat -c %y $UNDEPLOY_WAR | awk '{printf $1 "\n"}'`
#	if [ $DEST_FILE_DATE != $SOURCE_FILE_DATE ]; then
#		echo "!!!!!!!!!!!! File date does not match while copying war file '$FULL_SOURCE_WAR_NAME' to the deploy war '$UNDEPLOY_WAR'"
#		exit 1
#	fi

	# Now is the time to do post-deploy specific commands
#	${RUNTIME}_${APP_NAME}_postdeploy

	echo "<---deploy_app()"
}

###############################################
# Undeploy application
###############################################
undeploy_app()
{
	echo "--->undeploy_app(): UNDEPLOY_WAR='$UNDEPLOY_WAR'"
	STATUS=0
	COUNT=0
	while [ $STATUS = 0 ]
	do
		rm -rf $UNDEPLOY_WAR
		if [ -f "$UNDEPLOY_WAR" ]; then
			if [[ $COUNT -gt $APP_DEPLOY_TIMEOUT ]]; then
				echo "!!!!!!!! Error - we have waited long enough - the '$UNDEPLOY_WAR' app will never un-deploy"
				exit 1
			fi
			# since file has not yet been removed, need to wait a little more
			sleep 1
			(( COUNT++ ))
			echo "    Waiting $COUNT seconds for application '$UNDEPLOY_WAR' to un-deploy..."
		else
			# File has been removed
			STATUS=1
		fi
	done
	echo "<---undeploy_app()"
}

###############################################
# Wait for the application to get deployed
###############################################
wait_for_app_deploy()
{
	echo "--->wait_for_app_deploy(): APP_NAME='$APP_NAME'"
	test_app_url $APP_URL "$APP_TEST_STRING"
	# second test of the URL adds another couple of seconds to the measurement - for large apps it is OK, but for small apps it is not
#	test_app_url $APP_URL_secondary "$APP_TEST_STRING_secondary"
	echo "<---wait_for_app_deploy()"	
}

###############################################
# Wait for the application to get deployed
# Arguments:
# $1 - URL
# $2 - search string
###############################################
test_app_url()
{
	FULL_TEST_URL=$SERVER_HOST:$PORT/$1
	SEARCH_STRING=$2
	echo "--->test_app_url(): Looking for the '$SEARCH_STRING' string in response from the app: '$FULL_TEST_URL'"

	# Quick check for validity for input parameters
	if [[ $SEARCH_STRING == "" ]]; then
		echo "!!!!!!!! Error - input search string can not be empty"
		exit 1
	fi

	STATUS=0
	COUNT=0
	while [ $STATUS = 0 ]
	do
		# now check for the URL to be served by the server
		wget $FULL_TEST_URL --timeout $APP_DEPLOY_TIMEOUT -O - 2>/dev/null | grep "$SEARCH_STRING" >/dev/null
		if [ $? = 0 ]; then
			STATUS=1
		else
			if [[ $COUNT -gt $APP_DEPLOY_TIMEOUT ]]; then
				echo "!!!!!!!! Error - we have waited long enough - the '$UNDEPLOY_WAR' app will never deploy"
				exit 1
			fi
			# since correct string is not found, need to wait a little more
			sleep 1
			(( COUNT++ ))
			echo "    Waiting $COUNT seconds for application '$UNDEPLOY_WAR' to deploy..."
		fi
	done
	echo "<---test_app_url()"	
}

###############################################
# Remove log file
###############################################
remove_log_file()
{
	echo "--->remove_log_file()"
	rm -rf $STOP_LOG_FILE
	if [ -f "$STD_OUT_FILE" ]; then
		STATUS=0
		COUNT=0
		STATUS=0
		COUNT=0
		while [ $STATUS = 0 ]
		do
			rm -rf $STD_OUT_FILE
			if [ $? = 0 ]; then
				STATUS=1
			else
				if [[ $COUNT -gt $LOG_FILE_TIMEOUT ]]; then
    				echo "!!!!!!! We have waited long enough - error while removing the log file '$STD_OUT_FILE'"
					exit 1
				fi
				sleep 1
				(( COUNT++ ))
				echo "    Waiting $COUNT seconds for '$STD_OUT_FILE' log file to be released..."
			fi
		done
	fi
	echo "<---remove_log_file()"
}

###############################################
# Cleanup stuff from the server - or drop the server completely
###############################################
remove_server()
{
	echo "--->remove_server()"
	remove_log_file
	undeploy_app
	cleanup_server	
	echo "<---remove_server()"
}