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
# This script can be used to build a WAS-Liberty based OAuth-server docker container and
# configure it to use with IBM MessageSight Server.
#
# -------------------------------------------------------------------------------
# docker image name: libertyoauth
# docker image version: 1.0
# docker container name: libertyoauth
# -------------------------------------------------------------------------------
#
# Prereq:
# 1. This container requires WAS Liberty profile package. Please download the package from:
#    https://developer.ibm.com/wasdev/downloads/#asset/runtimes-wlp-javaee8
#    and copy the zip file in packages directory "../pkgs". Also replace the value of
#    variable WASPKGNAME with the name of the downloaded file.
#
# 2. Run ../configureNetworks.sh script to create Docker subnets needed for 
#    IBM IoT MessageSight demos.
#

#
# To build Liberty based OAuth server container
# ./oauthServer.sh build
#
# To run Liberty based OAuth server container
# ./oauthServer.sh run
#
# To remove Liberty based OAuth server container
# ./oauthServer.sh remove
#

WASPKGNAME="wlp-javaee8-18.0.0.3.zip"
export WASPKGNAME

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
    echo "ERROR: Invalid option is specified: $ARG1, $ARG2, $ARG3"
    echo "USAGE: Build, run, or remove Liberty based OAuth server for IBM IoT MessageSight v5 Server for demos."
    echo "       ./$0 <build|run|remove>"
    echo
    exit 1
}

# Check arguments
if [ $# -lt 1 ]
then
    usage
fi

ACTION=$1

# check is WAS Liberty profile image is available in the download directory
if [ ! -f ../pkgs/${WASPKGNAME} ]
then
    echo "WAS Liberty profile package is not available. Please download the package from:"
    echo "https://developer.ibm.com/wasdev/downloads/#asset/runtimes-wlp-javaee8"
    echo "and copy the zip file in download directory. Also replace the value of"
    echo "variable WASPKGNAME with the name of the downloaded file."
    exit 1
fi 


###############################
# Validate arguments
###############################
if [ "${ACTION}" == "build" ] || [ "${ACTION}" == "run" ] || [ "${ACTION}" == "remove" ]
then
    echo
    echo "${ACTION} Liberty based OAuth server."
else
    usage
fi


###############################
# Docker remove
###############################
if [ "${ACTION}" == "remove" ]
then
    sudo docker stop oauthserver
    sudo docker rm oauthserver
    sudo docker rmi -f oauthserver:1.0
fi


###############################
# Docker run
###############################
if [ "${ACTION}" == "run" ]
then
    mkdir -p ${MAPVOL}/oauthServerConfig
    sudo docker run -e LICENSE=accept \
        --net ms-service-net --ip 172.27.5.2 \
        --publish 9080:9080 --publish 9443:9443 \
        --memory 4G \
        --detach --interactive --tty --name oauthserver oauthserver:1.0
fi


###############################
# Docker Build
###############################
if [ "${ACTION}" == "build" ]
then
    # Update Dockerfile and buildServer.sh 
    sed 's/WASPKGNAME/'${WASPKGNAME}'/' Dockerfile.in > Dockerfile
    sed 's/WASPKGNAME/'${WASPKGNAME}'/' buildServer.sh.in > buildServer.sh
    sudo docker build --force-rm=true -t oauthserver:1.0 .
fi

echo
exit 0


