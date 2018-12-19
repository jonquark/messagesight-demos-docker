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
# MessageSight demo scripts following containers:
# - imawebui   - MessageSight WebUI
# - imaserver1 - MessageSight Server 1
# - imaserver2 - MessageSight Server 2
# - imaserver3 - MessageSight Server 3
# - imabridge  - MessageSight Bridge
# - openldap   - Open LDAP server
# - oauth      - WAS Liberty based Oauth server
# - snmptd     - SNMP Trap daemon 
# - mqserver   - IBM MQ server
# - activemq   - Apache active MQ server
#
# Docker bridge networking is used to configure network in the containses.
# All MessageSight containers like server, webui and bridge, share same subnets.
# For HA and cluster configurations, MessageSight server containers share 
# and additional subnet. All other containers that run external services
# required for demo environment, like openldap, oauth etc, are configured
# to use a different subnet.
#
# ms-server1-net: subnet=172.25.0.0/16 ip-range=172.25.5.0/16
# ms-server2-net: subnet=172.26.0.0/16 ip-range=172.26.5.0/16
# ms-service-net: subnet=172.27.0.0/16 ip-range=172.27.5.0/16
#
# IP addresses from ms-server-net assigned to MessageSight containers:
# MessageSight WebUI    - imawebui:   172.25.5.1
# MessageSight Bridge   - imabridge:  172.25.5.2
# MessageSight Server 1 - imaserver1: 172.25.5.3 and 172.26.5.3
# MessageSight Server 2 - imaserver2: 172.25.5.4 and 172.26.5.4
# MessageSight Server 3 - imaserver3: 172.25.5.5 and 172.26.5.5
#
# IP addresses from ms-service-net assigned to other containers:
# Open LDAP Server      - openldap:   172.27.5.1
# Liberty oAuth Server  - oauth:      172.27.5.2
# SNMP Trap Daemon      - trapd:      172.27.5.3
# IBM MQ Server         - mqserver:   172.27.5.4
# Active MQ Server      - activemq:   172.27.5.5
#

ACTION=$1

function usage() {
    echo
    echo "Creates or removes docker bridge networks used for MessageSight demos"
    echo "ERROR: Invalid option ${ACTION} is specified."
    echo "Usage: $0 <create|remove>"
    echo
    exit 1
}

if [ $# -ne 1 ]
then
    usage
fi

# Create networks
if [ "${ACTION}" == "create" ]
then
    echo
    echo "Docker networks for MessageSight Containers"
    sudo docker network create --subnet=172.25.0.0/16 --ip-range=172.25.5.0/16 --gateway=172.25.5.254 ms-server1-net
    sudo docker network create --subnet=172.26.0.0/16 --ip-range=172.26.5.0/16 --gateway=172.26.5.254 ms-server2-net
    echo
    echo "Docker network for external service Containers"
    sudo docker network create --subnet=172.27.0.0/16 --ip-range=172.27.5.0/16 --gateway=172.27.5.254 ms-service-net
    echo
    echo "List docker networks"
    sudo docker network ls
    echo
    exit 0
fi


# Remove networks
if [ "${ACTION}" == "remove" ]
then
    echo
    echo "Removing docker networks created for MessageSight containers"
    sudo docker network rm ms-server1-net
    sudo docker network rm ms-server2-net
    echo
    echo "Removing docker network created for external service containers"
    sudo docker network rm ms-service-net
    echo
    echo "List docker networks"
    sudo docker network ls
    echo
    exit 0
fi

usage

