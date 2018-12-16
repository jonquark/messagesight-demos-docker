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
# - MessageSight Server docker image (imaserver:5.0) in local registry
#   To build imaserver docker image:
#   $ cd openldap
#
# - Open LDAP Server docker image (openldap:1.0) in local registry
#   To build openldap image:
#   $ cd openldap
#   $ openldapDocker.sh build
#
#

# 
# To create and configure MessageSight Server and LDAP Containers
# ./ConfigureLDAPDemo.sh
#
# To clean MessageSight Server and Open LDAP containers
# ./ConfigureLDAPDemo.sh clean
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


ACTION=$1

# Delete old containers
if [ "${ACTION}" == "clean" ]
then
    echo "Stop MessageSight server container"
    sudo docker stop imaserver
    echo "Remove MessageSight server container"
    sudo docker rm -f imaserver
    echo "Remove MessageSight server container volumn: ${MAPVOL}/imaserver"
    sudo rm -rf ${MAPVOL}/imaserver
    exit 0
fi

#
# Create LDAP Container if not created yet
#
echo "Create openldap container"
cd openldap
./openldapDocker.sh run
echo "Connect docker network ms-server-net to the container"
sudo docker network connect ms-server-net openldap
echo "Wait for some time for LDAP server to configure and start properly"
sleep 30

#
# Create directory to MAP volumes of MessageSight Server container
# 
cd $CURDIR
echo "Create volume for MessageSight container"
mkdir -p ${MAPVOL}/imaserver/var/messagesight

#
# Create MessageSight container
#
# Expose - AdminPort and Default MQTT ports in the run command
# map 9089:9089 (Admin Endpoint), 1883:1883 (MQTT non-secured) and 8883:8883 (MQTT secured)
# Use docker network ms-demo-net
# Use volume ${MAPVOL}/imaserver/var/messagesight
#
#  Start first container - imaserver1
echo "Create imaserver container"
sudo docker run --cap-add SYS_ADMIN \
    --env-file=${CURDIR}/mstmpdir/server/IBMIoTMessageSightServer-docker.env \
    --net ms-server-net \
    --publish 9089:9089 --publish 1883:1883 --publish 8883:8883 \
    --volume ${MAPVOL}/imaserver/var/messagesight:/var/messagesight \
    --detach --memory 4G --interactive --tty --name imaserver imaserver:5.0

echo "Wait for imaserver container to start"
sleep 15
echo "Accept license"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{"LicensedUsage":"Production", "Accept": true}'
echo "Server gets restarted on license acceptance. Wait for 30 seconds for server to restart."
sleep 30
# Get status
curl -X GET http://127.0.0.1:9089/ima/v1/service/status

echo "Connect docker network ms-ldap-net to the container."
sudo docker network connect ms-ldap-net imaserver

#
# Configure External LDAP on imaserver
#
echo "Configure and Enable External LDAP on imaserver"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration \
  -d '{
        "LDAP": {
          "URL": "ldap://172.33.0.1",
          "BaseDN": "o=IBM",
          "BindDN": "cn=Manager,o=IBM",
          "BindPassword": "msDemoPassw0rd",
          "UserSuffix": "ou=users,ou=MessageSight,o=IBM",
          "GroupSuffix": "ou=groups,ou=MessageSight,o=ibm",
          "UserIdMap": "*:cn",
          "GroupIdMap": "*:cn",
          "GroupMemberIdMap": "member"
        }
     }'

echo "Test LDAP connection"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{ "LDAP":{"Verify":true}}'

echo "Enable LDAP"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{ "LDAP":{"Enabled":true}}'


#
# Configure connection policies to use LDAP group
#
echo "Update DemoConnectionPolicy"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{"ConnectionPolicy":{"DemoConnectionPolicy":{"GroupID":"*"}}}'

echo "Update DemoTopicPolicy"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{"TopicPolicy":{"DemoTopicPolicy":{"ClientID":"*","Topic":"toc/${GroupID}/${UserID}/*"}}}'

curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{"TopicPolicy":{"IPOSTPolicy":{"ClientID":"*","Topic":"toc/${GroupID}/*/${ClientID}*","ActionList":"Publish"}}}'

curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{"TopicPolicy":{"GIDPolicy":{"ClientID":"*","Topic":"${GroupID}/chat","ActionList":"Subscribe,Publish"}}}'

#
#
# Enable DemoEndpoint
#
echo "Enable DemoMqttEndpoint"
curl -X POST http://127.0.0.1:9089/ima/v1/configuration -d '{"Endpoint":{"DemoMqttEndpoint":{"Enabled":true, "TopicPolicies":"DemoTopicPolicy,IPOSTPolicy,GIDPolicy"}}}'

 


