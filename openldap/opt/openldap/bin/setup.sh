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
# Invokes ldapmodify to configure openldap for MessageSight
#

LOGFILE=/opt/openldap/setup.log

sleep 15

echo "===================" >> ${LOGFILE}
date >> ${LOGFILE}

COUNTER=40  # 40*3=2 minutes max wait
while [  $COUNTER -gt 0 ]; do
    sleep 3
    date >> ${LOGFILE}
    /usr/bin/ldapmodify -D "cn=Manager,o=IBM" -w msDemoPassw0rd -x -a -f /opt/openldap/users.ldif >> ${LOGFILE} 2>&1
    error=$?
    echo "Error: $error" >> ${LOGFILE}
    if [[ $error -eq 0 ]] ; then
        let COUNTER=0
    else
        if [[ $error -ne 68 ]] ; then
            let COUNTER=COUNTER-1
        else 
            let COUNTER=0
        fi
    fi
done
exit 0

