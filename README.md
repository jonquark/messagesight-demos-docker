# IBM IoT MessageSight v5 Demos
## Using docker containers

This project contains scripts to setup IBM IoT MessageSight demo environment using IBM IoT MessageSight
Server, WebUI, and Bridge containers, and other containers like OpenLDAP, OAuth, IBM MQ, SNMP trapd etc.

You can build and run MessageSight containers and other required containers on any operating environment that has docker-ce (Docker Community Edition) environment set. For information on Docker Community Edition for your operating environment, see Docker Communit Edition.

The following scripts are provided to setup different demostration cases:

1. configureNetworks.sh: Use this script to create docker networks used in different demo environment.

2. buildMSImages.sh: This script can be build MessageSight Server, WebUI, and Bridge docker images, or remove MessageSight Server, WebUI, and Bridge docker containers and associiated images.

3. configureWebUI.sh: This script runs a MessageSight WebUI container.

4. configureServer.sh: This script runs a MessageSight server container and configures the server to run demos.

### Prerequisite steps:

1. Setup docker CE environment on a system where docker CE is supported. For information on Docker Community Edition for your operating environment, see [Docker Communit Edition](https://store.docker.com/search?q=Docker%20Community%20Edition&type=edition&offering=community).

2. Clone this project:
```
$ git clone https://github.com/ibm-watson-iot/messagesight-demos-docker/develop
```

3. To build docker images needed to run IBM IoT MessageSight demos, you need to download some prerequite packages. Create a directory named "pkgs" to keep the downloaded packages.

4. Download IBM IoT MessageSight v5 install packages from [IBM IoT MessageSight v5](https://developer.ibm.com/iotplatform/2018/12/11/ibm-iot-messagesight-v5-announced/) and copy the files in the "pkgs" directory.

5. Download WAS Liberty profile package from [IBM WAS Liberty Profile](https://developer.ibm.com/wasdev/downloads/#asset/runtimes-wlp-javaee8) and copy the zip file in the "pkgs" directory.

6. The "pkgs" directory must contain the following files:
```
IBMIoTMessageSightServer-5.0.0.0.20181127-1958.tz
IBMIoTMessageSightBridge-5.0.0.0.20181127-1958.tz
IBMIoTMessageSightWebUI-5.0.0.0.20181127-1958.tz
wlp-javaee8-18.0.0.3.zip
```

### Build IBM IoT MessageSight docker images:

The script "buildMSImages.sh" can be used to:

- Build MessageSight Server, WebUI, and Bridge docker images.
- Remove MessageSight Server, WebUI, and Bridge docker containers and associiated images.

To build docker container image of MessageSight Server, WebUI or Bridge:
```
$ ./buildMSImages.sh <server|webui|bridge>
```

To remove MessageSight Server, WebUI, or Bridge container and image:
```
$ ./buildMSImages.sh <server|webui|bridge> remove
```


#####################################################################

    TODO:   Add steps to run configure and run demos

#####################################################################


