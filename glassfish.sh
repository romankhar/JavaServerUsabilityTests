#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

SERVER_INSTALL_DIR=$SERVER_HOME/glassfish4/glassfish
INSTANCE_DIR=$SERVER_INSTALL_DIR/domains/domain1 
STD_OUT_FILE=$INSTANCE_DIR/logs/server.log
STOP_LOG_FILE=$STD_OUT_FILE

PORT=8080
# admin console: http://localhost:4848

START_COMMAND="$SERVER_INSTALL_DIR/bin/asadmin start-domain"
START_MESSAGE="NCLS-CORE-00017"

STOP_COMMAND="$SERVER_INSTALL_DIR/bin/asadmin stop-domain"
STOP_MESSAGE="JMXStartupService and JMXConnectors have been shut down"

DEPLOY_DIR=$INSTANCE_DIR/autodeploy

###############################################
# Delete logs and other stuff from install dir
###############################################
cleanup_server()
{
	echo "--->cleanup_server()"
	rm -rf $DEPLOY_DIR
	mkdir $DEPLOY_DIR
	
	rm -rf $INSTANCE_DIR/applications
	mkdir $INSTANCE_DIR/applications

	rm -rf $INSTANCE_DIR/generated
	mkdir $INSTANCE_DIR/generated
	echo "<---cleanup_server()"
}

###############################################
# Create new server instance
###############################################
create_server()
{
	echo "<--->create_server()"
}

###############################################
# Just in case we need to do something
###############################################
glassfish_HelloWorld_predeploy()
{
	echo "<--->glassfish_HelloWorld_predeploy(): nothing to do"
}

glassfish_HelloWorld_postdeploy()
{
	echo "<--->glassfish_HelloWorld_postdeploy(): nothing to do"
}
