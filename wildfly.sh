#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

PORT=8080
SERVER_INSTALL_DIR=$SERVER_HOME/wildfly-9.0.1.Final
export JBOSS_HOME=$SERVER_INSTALL_DIR
STD_OUT_FILE="$SERVER_INSTALL_DIR/standalone/log/server.log"
#STOP_LOG_FILE="$SERVER_INSTALL_DIR/standalone/log/boot.log"
STOP_LOG_FILE=$STD_OUT_FILE

# Admin console: http://127.0.0.1:9990

START_COMMAND="jboss_start"
START_MESSAGE="WFLYSRV0025"
			
STOP_COMMAND="jboss_stop"
STOP_MESSAGE="WFLYSRV0050"

DEPLOY_DIR=$SERVER_INSTALL_DIR/standalone/deployments
#UNDEPLOY_APP_MESSAGE="JBAS018558"

###############################################
# Delete logs and other stuff from install dir
###############################################
cleanup_server()
{
	echo "cleanup_server()..."
	rm -rf $SERVER_INSTALL_DIR/standalone/log/*
	rm -rf $DEPLOY_DIR/$APP_NAME
	rm -rf $DEPLOY_DIR/*
}

###############################################
# Create new server instance
###############################################
create_server()
{
	echo "create_server()..."
	mkdir $DEPLOY_DIR
	cp server_configurations/wildfly/standalone.xml $SERVER_INSTALL_DIR/standalone/configuration
}


###############################################
# Start server 
###############################################
jboss_start()
{
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
wildfly_HelloWorld_predeploy()
{
	echo "<--->wildfly_HelloWorld_predeploy(): nothing to do"
}

wildfly_HelloWorld_postdeploy()
{
	echo "<--->wildfly_HelloWorld_postdeploy(): nothing to do"
}
