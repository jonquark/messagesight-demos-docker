#!/bin/bash
#
#*******************************************************************************
# Copyright (c) 2017-2018 IBM Corp.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# and Eclipse Distribution License v1.0 which accompany this distribution.
#
# The Eclipse Public License is available at
#    http://www.eclipse.org/legal/epl-v10.html
# and the Eclipse Distribution License is available at
#   http://www.eclipse.org/org/documents/edl-v10.php.
#
#
# Contrinutors:
#    Ranjan Dasgupta         - Initial drop
#
#*******************************************************************************
#

#
# ==============================================================================
#    SCRIPT IS PROVIDED TO CREATE MESSAGESIGHT DEMO ENVIRONMENT.
#    DO NOT USE THIS SCRIPT TO CREATE A PRODUCTION OR TEST ENVIRONMENT.
# ==============================================================================
#

# 
# This scripts can be used to run MessageSight Server docker container,
# and Open LDAP Server docker container. Open LDAP Server is configured
# as an external LDAP server in the MessageSight Server.
#
# PREREQ:
# - Create docker networks needed by IBM IoT MessageSight server and openLDAP 
#   server containers.
#   $ ./configureNetworks.sh create
#
# - Build IBM IoT MessageSight Server docker image (imaserver:5.0) in local registry
#   To build imaserver docker image:
#   $ ./buildMSImages.sh server
#
# - Build open LDAP Server docker image (openldap:1.0) in local registry
#   To build openLDAP Server image:
#   $ cd openLDAPServer
#   $ ./openldap.sh build
#
#

# 
# To create and configure open LDAP container and MessageSight Server Containers
# ./configureServer.sh
#
# To remove MessageSight Server and Open LDAP containers
# ./configureServer.sh remove
#
# To Reset MessageSight Server configuration
# ./configureServer.sh reset [force]
#

CURDIR=`pwd`
export CURDIR

OSTYPE=`uname -s`
export OSTYPE

MAPVOL=/mnt
if [ "${OSTYPE}" == "Darwin" ]
then
    MAPVOL=~/mnt
fi
export MAPVOL

ARG1=$1
ARG2=$2
ARG3=$3

function usage() {
    echo
    echo "ERROR: Invalid option(s) are specified: $ARG1, $ARG2, $ARG3"
    echo "USAGE: Configure, reset or remove IBM IoT MessageSight v5 Server for demos."
    echo "       ./$0 <configure|reset|remove> [force]"
    echo "       Default option is configure"
    echo "       Optional parameter force is valid for reset option."
    echo
    exit 1
}

# Validate command line options
if [ $# -gt 2 ]
then
    usage
fi

ACTION=$1
FORCE=$2

if [ "${ACTION}" == "" ]
then
    ACTION="configure"
fi

if [ "${FORCE}" != "" ] && [ "${FORCE}" != "force" ] 
then
    usage
fi

if [ "${ACTION}" != "configure" ] && [ "${ACTION}" != "reset" ] && [ "${ACTION}" != "remove" ]
then 
    usage
fi

if [ "${ACTION}" == "reset" ]
then
    if [ "${FORCE}" != "" ] && [ "${FORCE}" != "force" ]
    then
        usage
    fi
fi
        

echo
echo "IBM IoT MessageSight Server demo environment setup utility"
echo "Requested action: ${ACTION}"

#
# Check if server is already configured
#
inited=0
configured=0
if [ -f ${MAPVOL}/imaserver1/.inited ]
then
    inited=1
fi
if [ -f ${MAPVOL}/imaserver1/.configured ]
then
    configured=1
fi

echo "Current configuration states:"
echo "Inited:     $inited"
echo "Configured: $configured"
echo

# set configured to 0 for force reset option
if [ "${ACTION}" == "reset" ] && [ "${FORCE}" == "force" ] 
then
    echo "Configured is set to 1 because forced reset action is invoked."
    configured=1
fi


#
# Process remove action - remove old MessageSight container
#
if [ "${ACTION}" == "remove" ]
then
    if [ $inited -eq 0 ]
    then
        echo "ERROR: MessageSight server container is not found. Can not remove."
        exit 1
    fi

    echo "Stop MessageSight server container"
    sudo docker stop imaserver1
    echo "Remove MessageSight server container"
    sudo docker rm -f -v imaserver1
    echo "Remove MessageSight server container volumn: ${MAPVOL}/imaserver1"
    sudo rm -rf ${MAPVOL}/imaserver1
    exit 0
fi

#
# Create directory to MAP volumes of MessageSight Server container
#
if [ ! -d ${MAPVOL}/imaserver1/var/messagesight ]
then 
    echo "Create volume for MessageSight container"
    mkdir -p ${MAPVOL}/imaserver1/var/messagesight
fi

cd $CURDIR

#
# Create containers
#
if [ $inited -eq 0 ]
then
    #
    # Create LDAP Container if not created yet
    #
    echo "Check and create openldap container"
    cd openLDAPServer
    ./openldap.sh run
    echo "Connect docker network ms-server1-net to the container"
    sudo docker network connect ms-server1-net openldap
    echo "Wait for some time for LDAP server to configure and start properly"
    sleep 10
    cd $CURDIR

    #
    # Create MessageSight container
    #
    # Expose AdminEndpoint port - map 9089:9089
    # Expose Other endpoint ports for messaging
    # map 16102:16102 (Monitoring & Notification), 1883:1883 (MQTT non-secured) and 8883:8883 (MQTT secured)
    # Use docker network ms-server1-net
    # Use volume ${MAPVOL}/imaserver1/var/messagesight
    #
    echo "Create imaserver1 container"
    sudo docker run --cap-add SYS_ADMIN \
        --env-file=${CURDIR}/mstmpdir/server/IBMIoTMessageSightServer-docker.env \
        --net ms-server1-net \
        --publish 16102:16102 --publish 9089:9089 --publish 1883:1883 --publish 8883:8883 \
        --volume ${MAPVOL}/imaserver1/var/messagesight:/var/messagesight \
        --detach --memory 4G --interactive --tty --name imaserver1 imaserver:5.0

    echo "Wait for imaserver1 container to start"
    sleep 15
    echo "Accept license"
    curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{"LicensedUsage":"Production", "Accept": true}'
    echo "Server gets restarted on license acceptance. Wait for 30 seconds for server to restart."
    sleep 30
    echo "Check server status"
    curl -X GET http://127.0.0.1:9089/ima/v1/service/status

    echo "Connect docker network ms-service-net used for openldap server, to the container."
    sudo docker network connect ms-service-net imaserver1

    # containers are inited
    touch ${MAPVOL}/imaserver1/.inited
fi

#
# Configure MessageSight server
#
if [ $configured -eq 1 ]
then

    # check if config reset is initiated
    if [ "${ACTION}" == "reset" ]
    then
        # Reset MessageSight server configuration and accept license again
        echo "Reset server configuration"
        curl -X POST http://127.0.0.1:9089/ima/v1/service/restart -d '{"Service":"Server","Reset":"config"}'
        echo "Wait for imaserver1 container to start"
        sleep 15
        echo "Check server status"
        curl -X GET http://127.0.0.1:9089/ima/v1/service/status

        rm -f ${MAPVOL}/imaserver1/.configured
        exit 0
    else
        echo "MessageSight server is already configured to run demos"
        echo
        exit 0
    fi

else

    # check if config reset is initiated - not needed
    if [ "${ACTION}" == "reset" ]
    then
        echo "MessageSight server is not configured to run demo yet."
        echo "Server reset is not needed."
        exit 0
    fi

fi


#
# Delete Default Demo Endpoints and policies
#
echo "Delete DemoEndpoint"
curl -X DELETE http://127.0.0.1:9089/ima/v1/configuration/Endpoint/DemoEndpoint

echo "Delete DemoMqttEndpoint"
curl -X DELETE http://127.0.0.1:9089/ima/v1/configuration/Endpoint/DemoMqttEndpoint

echo "Delete DemoConnectionPolicy"
curl -X DELETE http://127.0.0.1:9089/ima/v1/configuration/ConnectionPolicy/DemoConnectionPolicy

echo "Delete DemoTopicPolicy"
curl -X DELETE http://127.0.0.1:9089/ima/v1/configuration/TopicPolicy/DemoTopicPolicy

#
# Configure Security related configuration objects
#
# Configure LDAP 
echo "Configure and Enable External LDAP on imaserver"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"LDAP": 
      {
          "URL": "ldap://172.27.5.1",
          "BaseDN": "o=IBM",
          "BindDN": "cn=Manager,o=IBM",
          "BindPassword": "msDemoPassw0rd",
          "UserSuffix": "ou=users,ou=MessageSight,o=IBM",
          "GroupSuffix": "ou=groups,ou=MessageSight,o=ibm",
          "UserIdMap": "*:cn",
          "GroupIdMap": "*:cn",
          "GroupMemberIdMap": "member"
  }}'

echo "Test LDAP connection"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{ "LDAP":{"Verify":true}}'

echo "Enable LDAP"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{ "LDAP":{"Enabled":true}}'

# Configure OAuth Profile
echo "Configure OAuth profile"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"OAuthProfile": {
    "TestOAuthProfile": {
      "ResourceURL": "http://172.27.5.2:9080/oauth2/endpoint/DemoProvider/token",
      "KeyFileName": "",
      "AuthKey": "access_token",
      "UserInfoURL": "",
      "UserInfoKey": "",
      "GroupInfoKey": ""
  }}}'

# Create Security Profile
echo "Configure Security Profile for OAuth and LDAP Authentication"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"SecurityProfile": {
    "TestSecProfile": {
      "TLSEnabled": false,
      "MinimumProtocolMethod": "TLSv1.2",
      "UseClientCertificate": false,
      "Ciphers": "Fast",
      "CertificateProfile": "",
      "UseClientCipher": false,
      "UsePasswordAuthentication": true,
      "OAuthProfile": "TestOAuthProfile"
  }}}'

#
# Configure connection policies
#
echo "Add connection policy for monitoring and notification"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"ConnectionPolicy": {
    "MonitoringConnectionPolicy": {
      "Description": "Connection policy for external monitoring and noficiation clients",
      "ClientID": "Monitor*",
      "ClientAddress": "",
      "UserID": "",
      "GroupID": "",
      "CommonNames": "",
      "Protocol": "",
      "AllowDurable": false,
      "AllowPersistentMessages": false,
      "ExpectedMessageRate": "Default"
    }}}'

echo "Add on open connection policy for other clients to connect"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"ConnectionPolicy": {
    "OpenConnectionPolicy": {
      "Description": "Connection policy for any client to connect",
      "ClientID": "*",
      "ClientAddress": "",
      "UserID": "",
      "GroupID": "",
      "CommonNames": "",
      "Protocol": "",
      "AllowDurable": true,
      "AllowPersistentMessages": true,
      "ExpectedMessageRate": "Default"
    }}}'

echo "Add Topic policy for SYSTEM topics - external monitoring and notification"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"TopicPolicy": {
    "MonitoringTopicPolicy": {
      "Description": "Topic policy for SYS topics",
      "ClientID": "Monitor*",
      "Topic": "$SYS/*",
      "ActionList": "Subscribe",
      "ClientAddress": "",
      "UserID": "",
      "GroupID": "",
      "CommonNames": "",
      "Protocol": "",
      "MaxMessages": 5000,
      "MaxMessagesBehavior": "RejectNewMessages",
      "MaxMessageTimeToLive": "unlimited",
      "DisconnectedClientNotification": false
    }}}'

echo "Add Topic policy for durable subscriber with disconnected notification option"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"TopicPolicy": {
    "DurableNotifPolicy": {
      "Description": "Topic policy for durable subscriber with disconnected notification",
      "ClientID": "GetNotif*",
      "UserID": "",
      "CommonNames": "",
      "ClientAddress": "",
      "GroupID": "",
      "Protocol": "MQTT",
      "Topic": "planets/earth",
      "ActionList": "Subscribe",
      "MaxMessages": 5000,
      "MaxMessagesBehavior": "RejectNewMessages",
      "DisconnectedClientNotification": true,
      "MaxMessageTimeToLive": "unlimited"
    }}}'


echo "Add Topic policy for other subscribers and publishers"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"TopicPolicy": {
    "TestTopicPolicy": {
      "Description": "Topic policy for subscribers and publishers",
      "ClientAddress": "",
      "UserID": "",
      "CommonNames": "",
      "ClientID": "IBMIoT*",
      "GroupID": "",
      "Protocol": "MQTT",
      "Topic": "*",
      "ActionList": "Publish,Subscribe",
      "MaxMessages": 5000,
      "MaxMessagesBehavior": "RejectNewMessages",
      "DisconnectedClientNotification": false,
      "MaxMessageTimeToLive": "unlimited"
    }}}'

# Non-secured endpoints for internal clients to get moitoring and notification messages 
echo "Create Endpoint for notification and monitoring clients"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"Endpoint": {
    "MonitoringEndpoint": {
      "Port": 16102,
      "Enabled": true,
      "Protocol": "All",
      "Interface": "All",
      "InterfaceName": "All",
      "ConnectionPolicies": "MonitoringConnectionPolicy",
      "TopicPolicies": "MonitoringTopicPolicy",
      "SubscriptionPolicies": null,
      "MaxMessageSize": "4096KB",
      "MessageHub": "DemoHub",
      "EnableAbout": true,
      "Description": "Unsecured endpoint for notification and monitoring MQTT clients.",
      "SecurityProfile": "",
      "MaxSendSize": 16384,
      "BatchMessages": true,
      "QueuePolicies": null
    }}}'


# Non-secured MqttEndpoint to handle disconnected clients
echo "Enable MqttEndpoint"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d \
  '{"Endpoint": {
    "MqttEndpoint": {
      "Port": 1883,
      "Enabled": true,
      "Protocol": "All",
      "Interface": "All",
      "InterfaceName": "All",
      "ConnectionPolicies": "OpenConnectionPolicy",
      "TopicPolicies": "DurableNotifPolicy,TestTopicPolicy",
      "SubscriptionPolicies": null,
      "MaxMessageSize": "4096KB",
      "MessageHub": "DemoHub",
      "EnableAbout": true,
      "Description": "Unsecured endpoint for external clients.",
      "SecurityProfile": "",
      "MaxSendSize": 16384,
      "BatchMessages": true,
      "QueuePolicies": null
    }}}'

# Mark setup complete
touch ${MAPVOL}/imaserver1/.configured


