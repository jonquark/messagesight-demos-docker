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
#    THIS DOCKERFILE IS PROVIDED TO BUILD A WAS-LIBERTY BASED OAUTH SERVER 
#    FOR MESSAGESIGHT DEMO ENVIRONMENT.
# ==============================================================================
#


#
# Dockerfile to build an OAuth Server using developers version of 
# IBM Websphere Liberty docker container image.
# For reference, refer to the following link:
# https://hub.docker.com/_/websphere-liberty/
#

FROM websphere-liberty:webProfile8
COPY --chown=1001:0  server.xml /config/
RUN installUtility install --acceptLicense defaultServer

