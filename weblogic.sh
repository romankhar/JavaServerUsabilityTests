#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

export MW_HOME=$SERVER_HOME/wls12130
SERVER_INSTALL_DIR=$MW_HOME/user_projects/domains/mydomain
LOG_DIR=$SERVER_INSTALL_DIR/servers/myserver/logs 
STD_OUT_FILE=$LOG_DIR/myserver.log
STOP_LOG_FILE=$STD_OUT_FILE
PORT=7001

# admin console: http://localhost:7001/console

START_COMMAND="weblogic_start"
START_MESSAGE="BEA-000360"

STOP_COMMAND="weblogic_stop"
STOP_MESSAGE="BEA-000238"

DEPLOY_DIR=$SERVER_INSTALL_DIR/autodeploy
#UNDEPLOY_APP_MESSAGE="BEA-149074"

###############################################
# Delete logs and other stuff from install dir
###############################################
cleanup_server()
{
	echo "cleanup_server()..."
	rm -rf $DEPLOY_DIR/*
}

###############################################
# Create new server instance
###############################################
create_server()
{
	echo "create_server()... do nothing"
	#$SERVER_INSTALL_DIR/bin/server create	
}

###############################################
# Start server 
###############################################
weblogic_start()
{
	( $SERVER_INSTALL_DIR/bin/startWebLogic.sh & ) > /dev/null 2>&1
}

###############################################
# Stop server 
###############################################
weblogic_stop()
{
	( $SERVER_INSTALL_DIR/bin/stopWebLogic.sh & ) > /dev/null 2>&1
}

###############################################
# Just in case we need to do something
###############################################
weblogic_HelloWorld_predeploy()
{
	echo "<--->weblogic_HelloWorld_predeploy(): nothing to do"
}

weblogic_HelloWorld_postdeploy()
{
	echo "<--->weblogic_HelloWorld_postdeploy(): nothing to do"
}
