#
# *****************************************************************************
# Copyright (c) 2020 IBM Corporation and other Contributors.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# *****************************************************************************
#
# Makefile to build Python Based Oauth Provider container for test.
#


export DOCKER_HUB_ID =
export DOCKER_HUB_PASSWORD =
export DOCKER_IMAGE_NAME = pyoauthserver
export DOCKER_IMAGE_VERSION = 1.0

ifdef DOCKER_HUB_ID
export DOCKER_IMAGE_PATH = $(DOCKER_HUB_ID)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
else
export DOCKER_IMAGE_PATH = $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
endif

default: all

all: dockerremove dockerimage dockerrun

dockerimage:
	@echo Build docker image $$DOCKER_IMAGE_NAME
	docker build -f Dockerfile -t $(DOCKER_IMAGE_PATH) .

dockerrun:
	@echo Run $$DOCKER_IMAGE_NAME container
	- docker network create --subnet=172.27.0.0/16 --ip-range=172.27.5.0/16 --gateway=172.27.5.254 ms-service-net
	docker run --net ms-service-net --ip 172.27.5.7 --publish 5000:5000 --memory 1G --detach --interactive --tty --name pyoauthserver pyoauthserver:1.0

dockercheck:
	@echo Check $$DOCKER_IMAGE_NAME container
	docker logs $(DOCKER_IMAGE_NAME)

dockerremove:
	@echo Stop and remove $$DOCKER_IMAGE_NAME container
	-docker rm -f $(DOCKER_IMAGE_NAME) 2> /dev/null || :
	-docker rmi -f $(DOCKER_IMAGE_PATH) 2> /dev/null || :

dockerstop:
	@echo Stop $$DOCKER_IMAGE_NAME container
	-docker stop $(DOCKER_IMAGE_NAME) 2> /dev/null || :

dockerstart:
	@echo Start $$DOCKER_IMAGE_NAME container
	-docker start $(DOCKER_IMAGE_NAME) 2> /dev/null || :


