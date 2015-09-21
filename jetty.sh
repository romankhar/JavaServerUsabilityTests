#!/bin/bash
# Author: Roman Kharkovski, IBM, blog: http://whywebsphere.com

SERVER_INSTALL_DIR=$SERVER_HOME/jetty-distribution-9.3.2.v20150730
JETTY_HOME=$SERVER_INSTALL_DIR
STD_OUT_FILE=$JETTY_HOME/logs/jetty.state
STOP_LOG_FILE=$STD_OUT_FILE

JETTY_PORT=8080
PORT=$JETTY_PORT
STOP_PORT=8079
JETTY_SECRET=secret

# this will call the function spceified below
START_COMMAND="jetty_start"
START_MESSAGE="INFO:oejs.Server:main: Started"

# this will call the function spceified below
STOP_COMMAND="jetty_stop"
STOP_MESSAGE="INFO:oejs.ServerConnector:ShutdownMonitor: Stopped ServerConnector"

DEPLOY_DIR=$JETTY_HOME/webapps
#UNDEPLOY_APP_MESSAGE="INFO:oejsh.ContextHandler:Scanner-0: Stopped o.e.j.w.WebAppContext"

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Jetty has a problem when issuing stop/start commands in very quick succession when Jenkins is running, hence need a small delay: http://osdir.com/ml/java.jetty.support/2004-01/msg00097.html
#JETTY_COMMAND_DELAY=5

###############################################
# Delete logs and other stuff from install dir 
###############################################
cleanup_server()
{
	echo "--->cleanup_server(): Jetty"
	rm -rf $JETTY_HOME/webapps.demo

	rm -rf $JETTY_HOME/logs
	mkdir $JETTY_HOME/logs

	rm -rf $JETTY_HOME/webapps
	mkdir $JETTY_HOME/webapps
	echo "<---cleanup_server()"
}

###############################################
# Create new server instance
###############################################
create_server()
{
	echo "<--->create_server(): nothing to do for Jetty"
}

###############################################
# Auto-generated function for special deployment tasks
###############################################
jetty_Jenkins_postdeploy()
{
	echo "--->jetty_Jenkins_postdeploy()"
	cp $PROJECT_HOME/server_configurations/jetty/jenkins.xml $JETTY_HOME/webapps
	jetty_stop
	jetty_start
	echo "<---jetty_Jenkins_postdeploy()"
}

###############################################
# Start jetty server 
###############################################
jetty_start()
{
    echo "--->jetty_start()"
    sleep $JETTY_COMMAND_DELAY
	cd $JETTY_HOME
	( $JAVA_HOME/bin/java -Djetty.http.port=$JETTY_PORT -DSTOP.PORT=$STOP_PORT -DSTOP.KEY=$JETTY_SECRET -jar start.jar &) > $STD_OUT_FILE 2>&1
    echo "<---jetty_start()"
}

###############################################
# Stop jetty server 
###############################################
jetty_stop()
{
    echo "--->jetty_stop()"
    sleep $JETTY_COMMAND_DELAY
	cd $JETTY_HOME
	$JAVA_HOME/bin/java -DSTOP.PORT=$STOP_PORT -DSTOP.KEY=$JETTY_SECRET -jar start.jar --stop
    echo "<---jetty_stop()"
}

###############################################
# Just in case we need to do something
###############################################
jetty_HelloWorld_predeploy()
{
	echo "<--->jetty_HelloWorld_predeploy(): nothing to do"
}

jetty_HelloWorld_postdeploy()
{
	echo "<--->jetty_HelloWorld_postdeploy(): nothing to do"
}
