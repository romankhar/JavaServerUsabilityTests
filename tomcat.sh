#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

PORT=8080
SERVER_INSTALL_DIR=$SERVER_HOME/apache-tomcat-8.0.26
export CATALINA_HOME=$SERVER_INSTALL_DIR
STD_OUT_FILE="$SERVER_INSTALL_DIR/logs/catalina.*.log"
STOP_LOG_FILE=$STD_OUT_FILE

START_COMMAND="$SERVER_INSTALL_DIR/bin/startup.sh"
START_MESSAGE="org.apache.catalina.startup.Catalina.start Server startup in"

STOP_COMMAND="$SERVER_INSTALL_DIR/bin/shutdown.sh"
STOP_MESSAGE="org.apache.coyote.AbstractProtocol.destroy Destroying ProtocolHandler"

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
	cp server_configurations/tomcat/server.xml $SERVER_INSTALL_DIR/conf
}

###############################################
# Since Tomcat appears to have a "hanging" problem  during fast subsequent redeployments of Jenkins, we need to remove the old WAR and then sleep a little
###############################################
tomcat_Jenkins_predeploy()
{
 	undeploy_app
 	sleep 5
}

###############################################
# Just in case we need to do something
###############################################
tomcat_HelloWorld_predeploy()
{
	echo "<--->tomcat_HelloWorld_predeploy(): nothing to do"
}

tomcat_HelloWorld_postdeploy()
{
	echo "<--->tomcat_HelloWorld_postdeploy(): nothing to do"
}
