#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

# ---------------------------- Now we include the utils script
source utils.sh

###############################################
# Test that measures how long it takes to start an existing server that already exists and was started some time before
###############################################
startExistingEmptyServer()
{
	# prep work - need to remove any existing old servers, create one, start it and stop it at least once
	stop_server
	remove_server
	create_server
	start_server
	short_sleep
	stop_server
	short_sleep
	
	# actual timed test
	start_timer
	start_server
	stop_timer
}

###############################################
# Restart existing server with an app in it deployed earlier
###############################################
restartExistingServerWithApp()
{
	# prep work
	setup_app $DefaultApp
	stop_server
	remove_server
	create_server
	start_server
	deploy_old_app
	wait_for_app_deploy
	long_sleep
	
	# actual timed test
	start_timer
	stop_server
	start_server
	wait_for_app_deploy
	stop_timer
}

###############################################
# Start existing server without any prep or cleanup of any sort
###############################################
stopWhateverExistingServer()
{
	start_timer
	stop_server
	stop_timer
} 

###############################################
# Stop existing server without any cleanup of any sort
###############################################
startWhateverExistingServer()
{
	start_timer
	start_server
	stop_timer
} 

###############################################
# Start server without cleanup of deployments
###############################################
startExistingServer()
{
	# actual timed test
	start_timer
	start_server
	stop_timer
} 

###############################################
# ReStart server without cleanup of deployments
###############################################
restartExistingServer()
{
	# actual timed test
	start_timer
	stop_server
	start_server
	stop_timer
} 

###############################################
# Deploy app into existing and running server
###############################################
deployAppInRunningServer()
{
	# prep work
	setup_app $DefaultApp
	stop_server
	remove_server
	create_server
	start_server
	long_sleep
	
	# actual timed test
	start_timer
	deploy_old_app
	wait_for_app_deploy
	stop_timer
}

###############################################
# Deploy app into stopped server
###############################################
deployAppAndStartServer()
{
	# prep work
	setup_app $DefaultApp
	stop_server
	remove_server
	create_server
	start_server
	short_sleep
	undeploy_app
	stop_server
	short_sleep
	
	
	# actual timed test
	start_timer
	deploy_old_app
	start_server
	wait_for_app_deploy
	stop_timer
}

###############################################
# Re-Deploy app in a server
###############################################
redeployJenkins()
{
	setup_app $JenkinsApp
	redeployAppInRunningServer
}

###############################################
# Re-Deploy app in a server
###############################################
redeployHelloWorld()
{
	setup_app $HelloWorldApp
	redeployAppInRunningServer
}

###############################################
# Re-Deploy app in a server
###############################################
redeployAppInRunningServer()
{
	# prep work
	stop_server
	remove_server
	create_server
	start_server
	deploy_old_app
	wait_for_app_deploy
	long_sleep
	
	# actual timed test
	start_timer
#	undeploy_app
	deploy_new_app
	# because the app may be quite large, we may need to sleep a little bit
	sleep $APP_REDEPLOY_SLEEP
	wait_for_app_deploy
	stop_timer
}

################################################################
# Run all targets in sequence
################################################################
default_target()
{
	echo "Usage: ./run.sh [<server_type> <task_name>]"
	echo "<Server_types>"
	for RUNTIME in $LIST_OF_SERVERS
	do
		echo "  -$RUNTIME"
	done
	echo "<Task_names>"
	for TASK in $LIST_OF_TASKS
	do
		echo "  -$TASK"
	done
    echo
    
    exit 1
}

################################################################
# Run one selected task
################################################################
run_test()
{
	echo "------------------ Begin test for Runtime='$RUNTIME', Task='$TASK'..."
    $TASK
	echo "------------------ End of test."
	echo -e "$RUNTIME\t$WAR_NAME\t$TASK\t$MEASURED_TIME" >> $RESULTS_FILE
}

################################################################
# Main
################################################################
#echo "$# input arguments provided: $1 $2"
echo
echo "Begin '$BASH_SOURCE' script..."
if [ $# -gt 1 ]; then
	RUNTIME=$1
	TASK=$2
	# ---------------------------- Now we include the script appropriate for whatever server runtime
	source $RUNTIME.sh
	run_test
else
	default_target
fi
echo "The '$BASH_SOURCE' script is done."