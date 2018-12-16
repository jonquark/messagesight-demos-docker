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
# This script creates and removes docker network used for MessageSight demos
#
# Consideration/requirements for docker run command to run multiple on same host, for example:
# Messagesight HA pairs, cluster nodes, Bridge, WebUI
# LDAP server, OAuth server, MQ Server, ActiveMQ etc
#
# Since you are creating multiple containers, you can not use host networking unless you 
# have multiple network interfaces configured on host system. So the best option is to use 
# docker bridge network option and create docker networks for different demo configurations.
#
# Subnet needed for different demos:
# MessageSight WebUI - 172.27.0.0/16 (ms-webui-net)
# MessageSight Servers
# - for Single node: 172.28.0.0/16 (ms-server-net)
# - for HA: 172.29.0.0/16 (ms-ha1-net) and 172.30.0.0/16 (ms-ha2-net)
# - for Cluster: 172.31.0.0/16 (ms-cn1-net) and 172.32.0.0/16 (ms-cn2-net)
# MessageSight Bridge - 172.33.0.0/16 (ms-bridge-net)
# LDAP server - 172.34.0.0/16 (ms-ldap-net)
# Oauth server - 172.35.0.0/16 (ms-oauth-net)
# MQ server - 172.36.0.0/16 (ms-mqserver-net)
# SNMP trapd server - 172.37.0.0/16 (ms-snmp-net)
# Acive MQ server - 172.38.0.0/16 (ms-amq-net)
# 

ACTION=$1
CONTAINER=$2

if [ "${ACTION}" == "create" ]
then
    echo

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "webui" ]
    then
        echo "Docker network for MessageSight WebUI"
        docker network create --subnet=172.27.0.0/16 --ip-range=172.27.5.0/16 --gateway=172.27.5.254 ms-webui-net
        echo
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "server" ]
    then
        echo "Docker network for Single MessageSight Server node"
        docker network create --subnet=172.28.0.0/16 --ip-range=172.28.5.0/16 --gateway=172.28.5.254 ms-server-net
        echo
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "ha" ]
    then
        echo "Docker networks for MessageSight server HA nodes"
        docker network create --subnet=172.29.0.0/16 --ip-range=172.29.5.0/16 --gateway=172.29.5.254 ms-ha1-net
        docker network create --subnet=172.30.0.0/16 --ip-range=172.30.5.0/16 --gateway=172.30.5.254 ms-ha2-net
        echo
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "cluster" ]
    then
        echo "Docker networks for MessageSight server cluster nodes"
        docker network create --subnet=172.31.0.0/16 --ip-range=172.31.5.0/16 --gateway=172.31.5.254 ms-cn1-net
        docker network create --subnet=172.32.0.0/16 --ip-range=172.32.5.0/16 --gateway=172.32.5.254 ms-cn2-net
        echo
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "bridge" ]
    then
        echo "Docker network for MessageSight bridger node"
        docker network create --subnet=172.33.0.0/16 --ip-range=172.33.5.0/16 --gateway=172.33.5.254 ms-bridge-net
        echo
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "ldap" ]
    then
        echo "Docker network for LDAP server"
        docker network create --subnet=172.34.0.0/16 --ip-range=172.34.5.0/16 --gateway=172.34.5.254 ms-ldap-net
        echo
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "oauth" ]
    then
        echo "Docker network for OAuth server"
        docker network create --subnet=172.35.0.0/16 --ip-range=172.35.5.0/16 --gateway=172.35.5.254 ms-oauth-net
        echo
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "mqserver" ]
    then
        echo "Docker network for MQ server"
        docker network create --subnet=172.36.0.0/16 --ip-range=172.36.5.0/16 --gateway=172.36.5.254 ms-mqserver-net
        echo
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "snmp" ]
    then
        echo "Docker network for SNMP Trapd"
        docker network create --subnet=172.37.0.0/16 --ip-range=172.37.5.0/16 --gateway=172.37.5.254 ms-snmp-net
        echo
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "amq" ]
    then
        echo "Docker network for ActiveMQ server"
        docker network create --subnet=172.38.0.0/16 --ip-range=172.38.5.0/16 --gateway=172.38.5.254 ms-amq-net
        echo
    fi

    echo "List docker networks"
    docker network ls
    echo
    exit 0
fi


ACTION=$1
if [ "${ACTION}" == "remove" ]
then
    echo
    echo "Removing docker networks created for MessageSight demos"
    echo

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "webui" ]
    then
        docker network rm ms-webui-net
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "server" ]
    then
        docker network rm ms-server-net
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "ha" ]
    then
        docker network rm ms-ha1-net
        docker network rm ms-ha2-net
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "cluster" ]
    then
        docker network rm ms-cn1-net
        docker network rm ms-cn2-net
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "bridge" ]
    then
        docker network rm ms-bridge-net
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "ldap" ]
    then
        docker network rm ms-ldap-net
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "oauth" ]
    then
        docker network rm ms-oauth-net
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "mqserver" ]
    then
        docker network rm ms-mqserver-net
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "snmp" ]
    then
        docker network rm ms-snmp-net
    fi

    if [ "${CONTAINER}" == "" ] || [ "${CONTAINER}" == "amq" ]
    then
        docker network rm ms-amq-net
    fi

    echo
    echo "List docker networks"
    docker network ls
    echo
    exit 0
fi

echo
echo "ERROR: Invalid option ${ACTION} is specified."
echo "Usage: $0 <create|remove> [container_name]"
echo
exit 1


