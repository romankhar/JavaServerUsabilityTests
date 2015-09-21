#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

PORT=8080
SERVER_INSTALL_DIR=$SERVER_HOME/apache-tomee-plus-1.7.2
export CATALINA_HOME=$SERVER_INSTALL_DIR
STD_OUT_FILE="$SERVER_INSTALL_DIR/logs/catalina.*.log"
STOP_LOG_FILE=$STD_OUT_FILE

# admin console: http://localhost:8080/

START_COMMAND="$SERVER_INSTALL_DIR/bin/startup.sh"
START_MESSAGE="INFO: Server startup in"

STOP_COMMAND="$SERVER_INSTALL_DIR/bin/shutdown.sh"
STOP_MESSAGE="INFO: Destroying ProtocolHandler"

DEPLOY_DIR=$SERVER_INSTALL_DIR/webapps
#UNDEPLOY_APP_MESSAGE="Undeploying context"

###############################################
# Delete logs and other stuff from install dir
###############################################
cleanup_server()
{
	echo "cleanup_server()..."
	rm -rf $SERVER_INSTALL_DIR/logs/*
	rm -rf $DEPLOY_DIR/webapps/examples
	rm -rf $DEPLOY_DIR/$APP_NAME
}

###############################################
# Create new server instance
###############################################
create_server()
{
	echo "create_server()..."
	cp server_configurations/tomee/server.xml $SERVER_INSTALL_DIR/conf
}

###############################################
# Since tomee appears to have a "hanging" problem  during fast subsequent redeployments of Jenkins, we need to remove the old WAR and then sleep a little
###############################################
tomee_Jenkins_predeploy()
{
 	undeploy_app
 	sleep 5
}

###############################################
# Just in case we need to do something
###############################################
tomee_HelloWorld_predeploy()
{
	echo "<--->tomee_HelloWorld_predeploy(): nothing to do"
}

tomee_HelloWorld_postdeploy()
{
	echo "<--->tomee_HelloWorld_postdeploy(): nothing to do"
}
