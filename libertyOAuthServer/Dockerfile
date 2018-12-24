#
#****************************************************************
# Licensed Materials - Property of IBM
# 5725-S17 IBM MessageSight
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#****************************************************************
#
################################################
#   This script is for internal IBM use only
################################################
#
# Dockerfile to build WAS-Liberty based OAuth Server
#

FROM centos:latest

WORKDIR /opt/ibm/wlp/bin

COPY ./download/wlp-javaee8-18.0.0.3.zip /tmp/
COPY ./server.xml /tmp/
COPY ./oauth2.jks /tmp/
COPY ./buildServer.sh /tmp/
COPY ./run.sh /bin/

RUN /tmp/buildServer.sh

ENTRYPOINT ["/bin/run.sh"]


