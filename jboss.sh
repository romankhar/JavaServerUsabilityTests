#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

# TODO - after fresh JBoss install, make sure to update the file 'standalone.xml' to change 'deployment-scanner' to scan-interval="100"

PORT=8080
SERVER_INSTALL_DIR=$SERVER_HOME/jboss-eap-6.4
export JBOSS_HOME=$SERVER_INSTALL_DIR
STD_OUT_FILE="$SERVER_INSTALL_DIR/standalone/log/server.log"
STOP_LOG_FILE=$STD_OUT_FILE

# Admin console: http://127.0.0.1:9990

START_COMMAND="jboss_start"
START_MESSAGE="JBAS015874"
			
STOP_COMMAND="jboss_stop"
STOP_MESSAGE="JBAS015950"

DEPLOY_DIR=$SERVER_INSTALL_DIR/standalone/deployments
#UNDEPLOY_APP_MESSAGE="JBAS018558"

###############################################
# Delete logs and other stuff from install dir
###############################################
cleanup_server()
{
	echo "cleanup_server()..."
	rm -rf $DEPLOY_DIR
	mkdir $DEPLOY_DIR
}

###############################################
# Create new server instance
###############################################
create_server()
{
	echo "create_server()..."
	cp server_configurations/jboss/standalone.xml $SERVER_INSTALL_DIR/standalone/configuration
}

###############################################
# Start server 
###############################################
jboss_start()
{
#	$SERVER_INSTALL_DIR/bin/standalone.sh
	( $SERVER_INSTALL_DIR/bin/standalone.sh & ) > /dev/null 2>&1
}

###############################################
# Stop server 
###############################################
jboss_stop()
{
	( $SERVER_INSTALL_DIR/bin/jboss-cli.sh --connect command=:shutdown & ) > /dev/null 2>&1
}

###############################################
# Just in case we need to do something
###############################################
jboss_HelloWorld_predeploy()
{
	echo "<--->jboss_HelloWorld_predeploy(): nothing to do"
}

jboss_HelloWorld_postdeploy()
{
	echo "<--->jboss_HelloWorld_postdeploy(): nothing to do"
}
