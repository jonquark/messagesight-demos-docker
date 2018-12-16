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
#    THIS DOCKERFILE IS PROVIDED TO BUILD AND RUN OPENLDAP SERVER 
#    FOR MESSAGESIGHT DEMO ENVIRONMENT.
# ==============================================================================
#

#
# Dockerfile to build an open ldap server to be used as
# an external LDAP server with IBM MessageSight V5 server.
#


FROM centos:latest

MAINTAINER ranjan.dasgupta@us.ibm.com

# Refer to man page for loglevel - http://linux.die.net/man/5/slapd.conf
ENV DEBUG_LEVEL=256
EXPOSE 389 636

# Update to last version

RUN yum -y update && \
    yum -y install net-tools openldap-servers openldap-clients && \
    yum clean all

CMD ["/usr/bin/run.sh"]

COPY ./opt.tar /tmp/
COPY run.sh /usr/bin/run.sh

