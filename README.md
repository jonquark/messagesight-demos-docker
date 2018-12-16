# IBM IoT MessageSight v5 Demos
## Using docker containers

This project contains scripts to setup IBM IoT MessageSight demo environment using IBM IoT MessageSight
Server, WebUI, and Bridge containers, and other containers like OpenLDAP, OAuth, IBM MQ, SNMP trapd etc.

You can build and run MessageSight containers and other required containers on any operating environment that has docker-ce (Docker Community Edition) environment set. For information on Docker Community Edition for your operating environment, see Docker Communit Edition.

The following scripts are provided to setup different demostration cases:

1. DockerMSImages.sh: Use this script to build IBM IoT MessageSight v5 Server, WebUI, and Bridge docker container images. 

2. DockerNetworks.sh: Use this script to create docker networks used in different demo environment.

3. ConfigureLDAPDemo.sh: This script runs and configures an openLDAP server and a MessageSight server containers for IBM IoT MessageSight and external LDAP integration demos.


## Install MessageSight in Docker environment

The script "DockerMSImages.sh" can be used to:

- Build MessageSight Server, WebUI, and Bridge docker images.
- Remove MessageSight Server, WebUI, and Bridge docker containers and associiated images.

### Prerequisite steps:

1. Setup docker CE environment on a system where docker CE is supported. For information on Docker Community Edition for your operating environment, see [Docker Communit Edition](https://store.docker.com/search?q=Docker%20Community%20Edition&type=edition&offering=community).

2. Download IBM IoT MessageSight v5 install packages from IBM site: [IBM IoT MessageSight v5](https://developer.ibm.com/iotplatform/2018/12/11/ibm-iot-messagesight-v5-announced/)

3. Create a directory "MessageSightV5_pkgs" and copy the downloaded files:
```
$ ls MessageSightV5_pkgs
IBMIoTMessageSightServer-5.0.0.0.20181127-1958.tz
IBMIoTMessageSightBridge-5.0.0.0.20181127-1958.tz
IBMIoTMessageSightWebUI-5.0.0.0.20181127-1958.tz
```

4. Clone this project:
```
$ git clone https://github.com/ibm-watson-iot/messagesight-demos-docker/develop
```

### Build IBM IoT MessageSight docker images:

The script "DockerMSImages.sh" can be used to:

- Build MessageSight Server, WebUI, and Bridge docker images.
- Remove MessageSight Server, WebUI, and Bridge docker containers and associiated images.

To build docker container image of MessageSight Server, WebUI or Bridge:
```
$ ./DockerMSImages.sh <server|webui|bridge>
```

To remove MessageSight Server, WebUI, or Bridge container and image:
```
$ ./DockerMSImages.sh <server|webui|bridge> remove
```



