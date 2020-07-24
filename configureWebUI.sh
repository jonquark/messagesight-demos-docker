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
# This scripts can be used to run IBM IoT MessageSight WebUI docker container to
# IBM IoT MessageSight Server containers.
#
# PREREQ:
# - Create docker networks needed by IBM IoT MessageSight webui container.
#   $ ./configureNetworks.sh create webui
#
# - MessageSight WebUI docker image (imaserver:5.0) in local registry
#   To build imawebui docker image:
#   $ ./buildMSImages.sh webui
#

# 
# To create IBM IoT MessageSight WebUI container
# ./configureWebUI.sh
#
# To remove IBM IoT MessageSight WebUI container
# ./configureWebUI.sh remove
#

CURDIR=`pwd`
export CURDIR

ACTION=$1

# Delete old containers
if [ "${ACTION}" == "remove" ]
then
    echo "Stop MessageSight webui container"
    sudo docker stop imawebui
    echo "Remove MessageSight webui container"
    sudo docker rm -f -v imawebui
    exit 0
fi

#
# Create MessageSight webui container
#
# Expose - webui admin port in the run command - map 8087:8087
# Use docker network ms-webui-net
#
echo "Create imawebui container"
sed -i'.bak' -e 's/127.0.0.1/0.0.0.0/g' ${CURDIR}/mstmpdir/webui/imawebui-docker.env
sudo docker run --cap-add SYS_ADMIN \
    --env-file=${CURDIR}/mstmpdir/webui/imawebui-docker.env \
    --net ms-server1-net --ip 172.25.5.1 --publish 9087:9087 \
    --detach --memory 2G --interactive --tty --name imawebui imawebui:5.0

