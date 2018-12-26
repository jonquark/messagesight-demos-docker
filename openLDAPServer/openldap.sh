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
# This script can be used to build a openldap docker container and
# configure it to use with IBM MessageSight Server as an external LDAP server.
# Use this for test only. 
# 
# -------------------------------------------------------------------------------
# docker image name: openldap
# docker image version: 1.0 
# docker container name: openldap
# -------------------------------------------------------------------------------
# 
# The openldap server is preconfigured to have groups and users that 
# can be used on IBM MessageSight policies:
#
# Group: MsgGroup1   Users: MsgUser1, MsgUser2
# Group: MsgGroup2   Users: MsgUser3, MsgUser4, MsgUser5
#
# Openldap bind password is set to msDemoPassw0rd
# Password for demo messaging users MsgUser1 ... MsgUser5 is set to testPassw0rd
# You can change these passwords by setting the following variable.
# If you want to use encrypted password, use slappasswd utility and set USERPASSWD
# password variable as following example:
# USERPASSWD={SSHA}v5MrH1YtbRqnBiNOZsAYY42x6ZefzRkJ
#
# NOTE:
# Openldap container requires docker netwrok ms-service-net. To create docker
# network used for various MessageSight demo containsers this script will 
# use script ../configureNetworks.sh (in the parent directory).
#
# 

BINDPASSWD=msDemoPassw0rd
USERPASSWD=testPassw0rd

ARG1=$1
ARG2=$2
ARG3=$3

CURDIR=`pwd`
export CURDIR

OSTYPE=`uname -s`
export OSTYPE

function usage() {
    echo
    echo "$0: Build, run or remove openldap docker image and container."
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
    sudo docker ps -a | grep openldap > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        containerExist=1
    fi
}

# start container
function start_container() {
    sudo docker ps -a | grep "openldap" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        # Start if not running 
        sudo docker ps -a | grep "openldap" | grep "Exited" > /dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo "Openldap container exists. Starting the continer."
            sudo docker start openldap > /dev/null 2>&1
        else
            echo "Openldap container is running."
        fi
    fi
}

# run container
function run_container() {
    echo "Run openldap docker container. Use docker network ms-service-net."
    sudo docker run --cap-add SYS_ADMIN -p 389:389 -p 636:636 -it -m 1G \
        --net ms-service-net --ip 172.27.5.1 --name openldap -d openldap:1.0

}

# Check if image exist
function check_image() {
    sudo docker images -a | grep "openldap" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo "Openldap docker image exists in the local repository."
    else
        build_image
    fi
}

# Build image
function build_image() {
    # Change passwords 
    if [ "${BINDPASSWD}" != "msDemoPassw0rd" ]
    then
        cd ${CURDIR}/opt/openldap
        cp slapd.conf.org slapd.conf
        sed -i'.bak' -e 's/msDemoPassw0rd/'${BINDPASSWD}'/g' slapd.conf
        rm -f slapd.conf.bak
    fi

    if [ "${USERPASSWD}" != "msDemoPassw0rd" ]
    then
        cd ${CURDIR}/opt/openldap
        cp users.ldif.org users.ldif
        sed -i'.bak' -e 's/msDemoPassw0rd/'${USERPASSWD}'/g' users.ldif
        rm -f users.ldif.bak
    fi

    cd ${CURDIR}
    tar czf opt.tar opt
    sudo docker build --force-rm=true -t openldap:1.0 .
}

# Check if image exist
function check_image() {
    sudo docker images -a | grep "openldap" > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        imageExist=1
    fi
}

# Stop and remove container
function remove_ldap_container() {
    check_container
    if [ $containerExist -eq 1 ]
    then
        sudo docker stop openldap
        sudo docker rm -f -v openldap
    else
        echo "Openldap docker container is not running."
    fi
}

# Remove image
function remove_ldap_image() {
    check_image
    if [ $imageExist -eq 1 ]
    then
        sudo docker rmi -f openldap:1.0
    else
        echo "Openldap docker image is not found."
    fi
}

#  Build docker image
if [ "$ACTION" == "build" ]
then
    echo "Building openldap docker image."
    check_image
    if [ $imageExist -eq 0 ]
    then
        build_image
    else
        echo "Openldap docker image exists."
    fi
    exit 0
fi

# Remove container and image
if [ "$ACTION" == "remove" ]
then
    echo "Removing openldap docker container."
    remove_ldap_container

    if [ "${TYPE}" == "image" ]
    then
        remove_ldap_image
    fi
    exit 0
fi

# Run container
if [ "$ACTION" == "run" ]
then
    echo "Running openldap docker container."
    check_image
    if [ $imageExist -eq 0 ]
    then
        echo "Openldap docker image is not found. Build docker image."
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

