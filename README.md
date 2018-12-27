# IBM IoT MessageSight v5 Demos
## Using docker containers

This project contains scripts to setup IBM IoT MessageSight demo environment using IBM IoT MessageSight
Server, WebUI, and Bridge containers, and other containers like OpenLDAP, OAuth, IBM MQ, SNMP trapd etc.

You can build and run MessageSight containers and other required containers on any operating environment 
that has docker-ce (Docker Community Edition) environment set.  For information on Docker Community Edition 
for your operating environment, see [About Docker CE](https://docs.docker.com/install/).

## List of demo use cases

| Feature | Available? | Description  |
|---------|:----------:|:-------------|
| External LDAP | Yes | Client authentication and messaging authorization using external LDAP server |
| OAuth Authentication | Yes | Client authentication using OAuth server |
| Client certificate | TBA | Client authentication using client certificates |
| Disconnected Client Notification | Yes | Send notification to disconnected durable subscribers |
| Subscription based Monitoring | Yes | Client to subscribe to monitoring statistics |
| High Availability | TBA | Messaging demo in MessgeSight High Availability environment |
| Cluster | TBA | Messaging demo using MessageSight cluster |
| MQConnectivity | TBA | Messaging demo in MQ Connectivity environment |
| MessageSight Bridge | TBA | Messaging demo in Messaging Bridge environment |
| SNMP | TBA | Monitoring statistics using SNMP trapd |

## Demo Configuration

The following scripts are provided to setup different demostration use cases:

1. configureNetworks.sh: Use this script to create docker networks used in different demo environment.

2. buildMSImages.sh: This script can be build MessageSight Server, WebUI, and Bridge docker images, or remove MessageSight Server, WebUI, and Bridge docker containers and associiated images.

3. configureWebUI.sh: This script runs a MessageSight WebUI container.

4. configureServer.sh: This script runs a MessageSight server container and other containers like openldap, oauthserver etc., and configures MessageSight server container to run demos.

### Prerequisite steps:

1. Setup docker CE environment on a system where docker CE is supported. For information on Docker Community Edition for your operating environment, see [About Docker CE](https://docs.docker.com/install/).

2. Clone this project:
```
$ git clone https://github.com/ibm-watson-iot/messagesight-demos-docker
```

3. To build docker images needed to run IBM IoT MessageSight demos, you need to download some prerequite packages. Create a directory named "pkgs" to keep the downloaded packages.

4. Download IBM IoT MessageSight v5 install packages from [IBM IoT MessageSight V5](http://www-01.ibm.com/common/ssi/ShowDoc.wss?docURL=/common/ssi/rep_ca/4/899/ENUSLP18-0494/index.html&lang=en&request_locale=en) and copy the files in the "pkgs" directory. The free for-developers edition will be available soon. Refer to [IBM IoT MessageSight](https://www.ibm.com/developerworks/downloads/iot/messagesight/index.html) for details.

5. The "pkgs" directory must contain the following files:
```
IBMIoTMessageSightServer-5.0.0.0.20181127-1958.tz
IBMIoTMessageSightBridge-5.0.0.0.20181127-1958.tz
IBMIoTMessageSightWebUI-5.0.0.0.20181127-1958.tz
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

### Configure MessageSight Server for demos

Use the followimng command to run a MessageSight server container and configure the server to run demos.
```
$ configureServer.sh 
```

### Build IBM IoT MessageSight test java client

To run the demos, you need to build MessageSight java client included in this project. To build the client code, you need Maven installed on your system. Refer to [Moven Getting started guide](https://maven.apache.org/guides/getting-started/index.html) for downloading and install instructions. Use the following commands to build MessageSight java test client:

```
$ cd testClients/ms-mqtt-java-sample
$ mvn clean package
```

## Demo use case descriptions and run steps

For demo environment details and how to run the demos, refer to the following links:

- [External LDAP](./demodocs/ldap.md)
- [OAuth Authentication](./demodocs/oauth.md)
- [Client certificate](./demodocs/certs.md)
- [Disconnected Client Notification](./demodocs/disconNotif.md)
- [Subscription based Monitoring](./demodocs/externalMonitoring.md)

