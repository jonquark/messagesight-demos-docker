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
# WAS-Liberty configuration for OAuth
#

yum -y update
yum -y install net-tools unzip java
yum clean all

mkdir -p /opt/ibm
cd /opt/ibm
pwd
unzip /tmp/wlp-javaee8-18.0.0.3.zip
ls
cd /opt/ibm/wlp
bin/installUtility install --acceptLicense jsp-2.2 security-1.0 appSecurity-1.0 servlet-3.0 ssl-1.0 oauth-2.0

bin/server create oauthServer
cp /tmp/server.xml /opt/ibm/wlp/usr/servers/oauthServer/.
mkdir -p /opt/ibm/wlp/usr/servers/oauthServer/resources/security
if [ -f /opt/ibm/wlp/usr/servers/oauthServer/resources/security/key.jks ]
then
    cp /opt/ibm/wlp/usr/servers/oauthServer/resources/security/key.jks /opt/ibm/wlp/usr/servers/oauthServer/resources/security/key.jks.org
fi
cp /tmp/oauth2.jks /opt/ibm/wlp/usr/servers/oauthServer/resources/security/key.jks

bin/server start oauthServer
bin/server stop oauthServer




