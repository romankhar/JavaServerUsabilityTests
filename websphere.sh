#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

SERVER_INSTALL_DIR=$SERVER_HOME/ibm/WAS855
PROFILE_NAME="AppSrv01"
INSTANCE_DIR="$SERVER_INSTALL_DIR/profiles/$PROFILE_NAME"
#STD_OUT_FILE="$INSTANCE_DIR/logs/server1/SystemOut.log"
STD_OUT_FILE="$INSTANCE_DIR/logs/server1/startServer.log"
STOP_LOG_FILE="$INSTANCE_DIR/logs/server1/stopServer.log"
PORT=9080

# admin console: http://localhost:9060/ibm/console

START_COMMAND="$INSTANCE_DIR/bin/startServer.bat server1 -profileName $PROFILE_NAME"
START_MESSAGE="ADMU3000I"

STOP_COMMAND="$INSTANCE_DIR/bin/stopServer.bat server1 -profileName $PROFILE_NAME"
#STOP_MESSAGE="WSVR0024I"
STOP_MESSAGE="ADMU4000I"

DEPLOY_DIR="$INSTANCE_DIR/monitoredDeployableApps/servers/server1"
#UNDEPLOY_APP_MESSAGE="CWLDD0008I"

###############################################
# Delete logs and other stuff from install dir
###############################################
cleanup_server()
{
	echo "cleanup_server()..."
	rm -rf $INSTANCE_DIR/installedApps/RomanW530Node02Cell/* 
	rm -rf $INSTANCE_DIR/monitoredDeployableApps/servers/server1/*
	rm -rf $INSTANCE_DIR/logs/server1/*
	rm -rf $INSTANCE_DIR/config/cells/RomanW530Node02Cell/applications/$APP_NAME*
}

###############################################
# Create new server instance
###############################################
create_server()
{
	echo "create_server()... do nothing"
	# do not need to do anything here
}

###############################################
# Just in case we need to do something
###############################################
websphere_HelloWorld_predeploy()
{
	echo "<--->websphere_HelloWorld_predeploy(): nothing to do"
}

websphere_HelloWorld_postdeploy()
{
	echo "<--->websphere_HelloWorld_postdeploy(): nothing to do"
}
