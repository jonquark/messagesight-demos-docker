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
# This script can be used to build and run oauthserver docker container and
# configure IBM MessageSight Server to use for client authentication using
# OAuth authentication option.
# 
# -------------------------------------------------------------------------------
# docker image name: oauthserver
# docker image version: 1.0 
# docker container name: oauthserver
# -------------------------------------------------------------------------------
# 
# The oauthserver server is preconfigured with set of users that 
# IBM IoT MessageSight clients can use to connect.
# Password for demo messaging users MsgUser1 ... MsgUser5 is set to testPassw0rd
# You can change these passwords by editing server.xml file.
#
# NOTE:
# The oauthserver container requires docker netwrok ms-service-net. To create docker
# network used for various MessageSight demo containsers this script will 
# use script ../configureNetworks.sh (in the parent directory).
#
# 

ARG1=$1
ARG2=$2
ARG3=$3

CURDIR=`pwd`
export CURDIR

OSTYPE=`uname -s`
export OSTYPE

function usage() {
    echo
    echo "$0: Build, run or remove oauthserver docker image and container."
    echo "ERROR: Invalid option(s) ar specified: $ARG1, $ARG2, $ARG3"
    echo "USAGE: $0 <build|run|remove> [image]"
    echo
    exit 1
}

ACTION=$1
TYPE=$2

if [ $# -gt 2 ]
then
    usage
fi

imageExist=0
containerExist=0

# Create network if not present
function check_create_network() {
    # check if ms-service-net is created
    sudo docker network ls | grep ms-service-net > /dev/null 2>&1
    if [ $? -eq 1 ]
    then
        ../configureNetworks.sh create
    fi
}

# check if container exist
function check_container() {
    sudo docker ps -a | grep oauthserver > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        containerExist=1
    fi
}

# start container
function start_container() {
    sudo docker ps -a | grep "oauthserver" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        # Start if not running 
        sudo docker ps -a | grep "oauthserver" | grep "Exited" > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo "OAuth server container exists. Starting the continer."
            sudo docker start oauthserver > /dev/null 2>&1
        else
            echo "OAuth server container is running."
        fi
    fi
}

# run container
function run_container() {
    echo "Run oauthserver docker container. Use docker network ms-service-net."
    sudo docker run \
        --net ms-service-net --ip 172.27.5.2 \
        --publish 9080:9080 --publish 9443:9443 \
        --memory 2G \
        --detach --interactive --tty --name oauthserver oauthserver:1.0
}

# Check if image exist
function check_image() {
    sudo docker images -a | grep "oauthserver" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo "OAuth server docker image exists in the local repository."
    else
        build_image
    fi
}

# Build image
function build_image() {

    cd ${CURDIR}
    sudo docker build --force-rm=true -t oauthserver:1.0 .
}

# Check if image exist
function check_image() {
    sudo docker images -a | grep "oauthserver" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        imageExist=1
    fi
}

# Stop and remove container
function remove_oauth_container() {
    check_container
    if [ $containerExist -eq 1 ]
    then
        sudo docker stop oauthserver
        sudo docker rm -f -v oauthserver
    else
        echo "OAuth server docker container is not running."
    fi
}

# Remove image
function remove_oauth_image() {
    check_image
    if [ $imageExist -eq 1 ]
    then
        sudo docker rmi -f oauthserver:1.0
    else
        echo "OAuth server docker image is not found."
    fi
}

#  Build docker image
if [ "$ACTION" == "build" ]
then
    echo "Building oauthserver docker image."
    check_image
    if [ $imageExist -eq 0 ]
    then
        build_image
    else
        echo "OAuth server docker image exists."
    fi
    exit 0
fi

# Remove container and image
if [ "$ACTION" == "remove" ]
then
    echo "Removing oauthserver docker container."
    remove_oauth_container

    if [ "${TYPE}" == "image" ]
    then
        remove_oauth_image
    fi
    exit 0
fi

# Run container
if [ "$ACTION" == "run" ]
then
    echo "Running oauthserver docker container."
    check_image
    if [ $imageExist -eq 0 ]
    then
        echo "OAUth server docker image is not found. Build docker image."
        build_image
    fi
    check_create_network
    check_container
    if [ $containerExist -eq 1 ]
    then
        start_container
    else
        run_container
    fi
    exit 0
fi

usage

