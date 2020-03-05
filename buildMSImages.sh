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
# This script can be used to build following docker images for 
# IBM IoT MessageGateway 5.0.0 demos:
#
# - MessageGateway Server 
#   docker image name: imaserver
#   docker image version: 5.0
#
# - MessageGateway WebUI
#   docker image name: imawebui
#   docker image version: 5.0
#
# - MessageGateway Bridge
#   docker image name: imabridge
#   docker image version: 5.0
#
# 
# Prereq steps:
#
# - Install Docker Community Edition on your system. For details refer to:
#   https://docs.docker.com/install/
#
# - Create a directory pkgs
#
# - Download the latest install images of IBM MessageGateway Server, WebUI, and Bridge
#   from IBM FixCentral or Pasport advantage and copy the files in the pkgs directory.
#
SERVER_IMAGE_NAME="IBMWIoTPMessageGatewayServer-5.0.0.2.20200229-1733.tz"
WEBUI_IMAGE_NAME="IBMWIoTPMessageGatewayWebUI-5.0.0.2.20200107-2200.tz"
BRIDGE_IMAGE_NAME="IBMWIoTPMessageGatewayBridge-5.0.0.2.20200107-2200.tz"

CURDIR=`pwd`
export CURDIR

PKGDIR=${CURDIR}/pkgs
export PKGDIR

SERVERTYPE=$1
REMOVE=$2

function usage() {
    echo
    echo "$0: Creates or removes MessageGateway Server, WebUI, and/or Bridge docker images."
    echo "ERROR: Invalid option(s) are spcified: ${SERVERTYPE}, ${REMOVE}"
    echo "USAGE: $0 <server|webui|bridge|all> [remove]"
    echo
    exit 1
}

# Check if REMOVE option is valid
if [ "${REMOVE}" != "" ] && [ "${REMOVE}" != "remove" ]
then
    usage
fi

#
# Check if prereq packages are downloaded and available in pkgs direcrtory
if [ ! -f ${PKGDIR}/${SERVER_IMAGE_NAME} ] || [ ! -f ${PKGDIR}/${WEBUI_IMAGE_NAME} ] || [ ! -f ${PKGDIR}/${BRIDGE_IMAGE_NAME} ]
then
    echo
    echo "ERROR: Required packages for the build to complete are not available."
    echo "       Download the latest install images of IBM MessageGateway Server, WebUI, and Bridge"
    echo "       from IBM FixCentral or Pasport advantage and copy the files in the pkgs directory."
    echo
    exit 1
fi

done=0

#
# Build or remove Server image
#
if [ "${SERVERTYPE}" == "server" ] || [ "${SERVERTYPE}" == "all" ]
then
    buildExist=0
    sudo docker images -a | grep "imaserver" | grep "5.0" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        buildExist=1
    fi

    if [ "${REMOVE}" == "remove" ]
    then
        if [ $buildExist -eq 1 ]
        then
            echo "Removing MessageGateway Server docker image."
            docker rmi -f imaserver:5.0
        else
            echo "MessageGateway Server docker image doesn't exist."
        fi
    else
        if [ $buildExist -eq 1 ]
        then
            echo "MessageGateway Server docker image already exists."
        else
            echo "Building MessageGateway Server docker image"
            mkdir -p ${CURDIR}/mstmpdir/server
            cd ${CURDIR}/mstmpdir/server
            tar zxf ${PKGDIR}/${SERVER_IMAGE_NAME}
            cp IBMWIoTPMessageGatewayServer-*.rpm imaserver.rpm
            sudo docker build --force-rm=true -t imaserver:5.0 .
        fi
    fi
    done=1
fi

#
# Build or remove WebUI image
#
if [ "${SERVERTYPE}" == "webui" ] || [ "${SERVERTYPE}" == "all" ]
then
    buildExist=0
    sudo docker images -a | grep "imawebui" | grep "5.0" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        buildExist=1
    fi

    if [ "${REMOVE}" == "remove" ]
    then
        if [ $buildExist -eq 1 ]
        then
            echo "Removing MessageGateway WebUI docker image."
            docker rmi -f imawebui:5.0
        else
            echo "MessageGateway WebUI docker image doesn't exist."
        fi 
    else
        if [ $buildExist -eq 1 ]
        then
            echo "MessageGateway WebUI docker image already exists."
        else
            echo "Building MessageGateway WebUI docker image."
            mkdir -p ${CURDIR}/mstmpdir/webui
            cd ${CURDIR}/mstmpdir/webui
            tar zxf ${PKGDIR}/${WEBUI_IMAGE_NAME}
            cp IBMIoTMessageGatewayWebUI-*.rpm imawebui.rpm
            sudo docker build --force-rm=true -t imawebui:5.0 .
        fi
    fi
    done=1
fi

#
# Build or remove Bridge image
#
if [ "${SERVERTYPE}" == "bridge" ] || [ "${SERVERTYPE}" == "all" ]
then
    buildExist=0
    sudo docker images -a | grep "imabridge" | grep "5.0" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        buildExist=1
    fi

    if [ "${REMOVE}" == "remove" ]
    then
        if [ $buildExist -eq 1 ]
        then
            echo "Removing MessageGateway Bridge docker image."
            docker rmi -f imabridge:5.0
        else
            echo "MessageGateway Bridge docker image doesn't exist."
        fi
    else
        if [ $buildExist -eq 1 ]
        then
            echo "MessageGateway Bridge docker image already exists"
        else
            echo "Buildiing MessageGateway Bridge docker image"
            mkdir -p ${CURDIR}/mstmpdir/bridge
            cd ${CURDIR}/mstmpdir/bridge
            tar zxf ${PKGDIR}/${BRIDGE_IMAGE_NAME}
            cp IBMIoTMessageGatewayBridge-*.rpm imabridge.rpm
            sudo docker build --force-rm=true -t imabridge:5.0 .
        fi
    fi
    done=1
fi

if [ $done -eq 0 ]
then
    usage
else
    echo
    exit 0
fi

