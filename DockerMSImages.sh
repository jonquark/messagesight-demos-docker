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
# IBM IoT MessageSight 5.0.0 demos:
#
# - MessageSight Server 
#   docker image name: imaserver
#   docker image version: 5.0
#
# - MessageSight WebUI
#   docker image name: imawebui
#   docker image version: 5.0
#
# - MessageSight Bridge
#   docker image name: imabridge
#   docker image version: 5.0
#
# 
# Prereq steps:
#
# - Install Docker Community Edition on your system. For details refer to:
#   https://docs.docker.com/install/
#
# - Create a directory MessageSightV5_pkgs
#
# - Download the latest install images of IBM MessageSight Server, WebUI, and Bridge
#   from IBM FixCentral or Pasport advantage and copy the files in MessageSightV5_pkgs 
#   directory
#
SERVER_IMAGE_NAME="IBMIoTMessageSightServer-5.0.0.0.20181127-1958.tz"
WEBUI_IMAGE_NAME="IBMIoTMessageSightWebUI-5.0.0.0.20181127-1958.tz"
BRIDGE_IMAGE_NAME="IBMIoTMessageSightBridge-5.0.0.0.20181127-1958.tz"

CURDIR=`pwd`
export CURDIR

PKGDIR=${CURDIR}/../MessageSightV5_pkgs
export PKGDIR

SERVERTYPE=$1
CLEANUP=$2

imageExist=0

#
# Build docker docker
#
if [ "${SERVERTYPE}" == "server" ]
then
    sudo docker images -a | grep "imaserver:5.0" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        if [ "${CLEANUP}" == "" ]
        then
            echo "MessageSight Server docker image already exists"
            echo
            exit 1
        else
            echo "MessageSight Server docker image doesn't exist"
            echo
            exit 1
        fi
    fi

    if [ "${CLEANUP}" == "remove" ]
    then
        echo
        echo "Remove MessageSight Server docker image"
        docker rmi -f imaserver:5.0
    else
        echo
        echo "Build MessageSight Server docker image"
        mkdir -p ${CURDIR}/mstmpdir/server
        cd ${CURDIR}/mstmpdir/server
        tar zxf ${PKGDIR}/${SERVER_IMAGE_NAME}
        cp IBMIoTMessageSightServer-*.rpm imaserver.rpm
        sudo docker build --force-rm=true -t imaserver:5.0 .
    fi
    echo
    exit 0
fi

if [ "${SERVERTYPE}" == "webui" ]
then
    sudo docker images -a | grep "imawebui:5.0" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        if [ "${CLEANUP}" == "" ]
        then
            echo "MessageSight WebUI docker image already exists"
            echo
            exit 1
        else
            echo "MessageSight WebUI docker image doesn't exist"
            echo
            exit 1
        fi
    fi

    if [ "${CLEANUP}" == "remove" ]
    then
        echo
        echo "Remove MessageSight WebUI docker image"
        docker rmi -f imawebui:5.0
    else
        echo
        echo "Build MessageSight WebUI docker image"
        mkdir -p ${CURDIR}/mstmpdir/webui
        cd ${CURDIR}/mstmpdir/webui
        tar zxf ${PKGDIR}/${WEBUI_IMAGE_NAME}
        cp IBMIoTMessageSightWebUI-*.rpm imawebui.rpm
        sudo docker build --force-rm=true -t imawebui:5.0 .
    fi
    echo
    exit 0
fi

if [ "${SERVERTYPE}" == "bridge" ]
then
    sudo docker images -a | grep "imabridge:5.0" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        if [ "${CLEANUP}" == "" ]
        then
            echo "MessageSight Bridge docker image already exists"
            echo
            exit 1
        else
            echo "MessageSight Bridge docker image doesn't exist"
            echo
            exit 1
        fi
    fi

    if [ "${CLEANUP}" == "remove" ]
    then
        echo
        echo "Remove MessageSight Bridge docker image"
        docker rmi -f imabridge:5.0
    else
        echo
        echo "Build MessageSight Bridge docker image"
        mkdir -p ${CURDIR}/mstmpdir/bridge
        cd ${CURDIR}/mstmpdir/bridge
        tar zxf ${PKGDIR}/${BRIDGE_IMAGE_NAME}
        cp IBMIoTMessageSightBridge-*.rpm imabridge.rpm
        sudo docker build --force-rm=true -t imabridge:5.0 .
    fi
    echo
    exit
fi

echo
echo "ERROR: Invalid option is spcified"
echo "USAGE: $0 <server|webui|bridge> [remove]"
echo
exit 1

