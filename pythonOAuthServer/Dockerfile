#
#*******************************************************************************
# Copyright (c) 2028 IBM Corp.
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
#    THIS DOCKERFILE IS PROVIDED TO BUILD A PYTHON BASED SIMPLE OAUTH SERVER
#    FOR TESTING OAUTH
# ==============================================================================
#
# Token endpoint:     http://127.0.0.1:5000/oauth2/endpoint/PythonOAuthProvider/token
# Authorize endpoint: http://127.0.0.1:5000/oauth2/endpoint/PythonOAuthProvider/authorize
#

FROM python:3
RUN apt-get update
RUN apt-get install -y vim net-tools
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD [ "python", "./server.py" ]

