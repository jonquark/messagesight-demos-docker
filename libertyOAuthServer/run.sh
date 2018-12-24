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
# Entry point script for OAuth server
# - for IBM IoT MessageSight test environment
#


_term() {
    trap - SIGTERM
    echo "SIGTERM in start openldap Server script"
    LOOP=0
}

# Start server
cd /opt/ibm/wlp
bin/server start oauthServer

LOOP=1

# Loop for ever
while [ $LOOP -gt 0 ];
do
    sleep 300
    if [ $LOOP -eq 0 ]
    then
        echo "OAuth Server is terminated" $?
        exit 15
    fi
done


