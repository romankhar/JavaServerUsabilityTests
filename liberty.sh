#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

SERVER_INSTALL_DIR=$SERVER_HOME/wlp-javaee7-8.5.5.7/wlp
INSTANCE_NAME=defaultServer
INSTANCE_DIR=$SERVER_INSTALL_DIR/usr/servers/$INSTANCE_NAME
STD_OUT_FILE=$INSTANCE_DIR/logs/console.log
STOP_LOG_FILE=$STD_OUT_FILE

PORT=9080

START_COMMAND="$SERVER_INSTALL_DIR/bin/server start"
START_MESSAGE="The server $INSTANCE_NAME is ready to run a smarter planet"

STOP_COMMAND="$SERVER_INSTALL_DIR/bin/server stop"
STOP_MESSAGE="The server $INSTANCE_NAME stopped after"

DEPLOY_DIR=$INSTANCE_DIR/dropins
#UNDEPLOY_APP_MESSAGE="CWWKZ0009I"

###############################################
# Delete logs and other stuff from install dir
###############################################
cleanup_server()
{
	echo "--->cleanup_server()"
	rm -rf $INSTANCE_DIR
	echo "<---cleanup_server()"
}

###############################################
# Create new server instance
###############################################
create_server()
{
	echo "--->create_server()"
	$SERVER_INSTALL_DIR/bin/server create	
	cp server_configurations/ibm-liberty/server.xml $INSTANCE_DIR
	echo "<---create_server()"
}

###############################################
# Just in case we need to do something
###############################################
liberty_HelloWorld_predeploy()
{
	echo "<--->liberty_HelloWorld_predeploy(): nothing to do"
}

liberty_HelloWorld_postdeploy()
{
	echo "<--->liberty_HelloWorld_postdeploy(): nothing to do"
}