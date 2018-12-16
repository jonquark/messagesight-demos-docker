#!/bin/bash
#
#*******************************************************************************
# Copyright (c) 2018 IBM Corp.
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
# Entry point script for openldap docker container that can be used
# in IBM IoT MessageSight demos.
#

_term() {
    trap - SIGTERM
    echo "SIGTERM in start openldap Server script"
    LOOP=0
}

# install config files
mkdir -p /opt/openldap/openldap-data
if [ ! -f /opt/openldap/openldap-data/.installed ]
then
    cd /
    tar xf /tmp/opt.tar
    rm -f /tmp/opt.tar
    touch /opt/openldap/openldap-data/.installed
fi

# TODO: Set server host using environment variable in docker run command
LDAP_URL="ldap://0.0.0.0"
export LDAP_URL

# Start slapd
/usr/sbin/slapd -h ${LDAP_URL} -f /opt/openldap/slapd.conf -g root &

# Run setup to set default users/groups
if [ ! -f /opt/openldap/openldap-data/.setup_done ]
then
    /opt/openldap/bin/setup.sh &
    touch /opt/openldap/openldap-data/.setup_done
fi

# Loop for ever - till container is stopped or slapd process is terminated
LOOP=1
while [ $LOOP -gt 0 ];
do
    sleep 300
    if [ $LOOP -eq 0 ]
    then
        echo "openldap Server terminated" $?
        exit 15
    fi
done


