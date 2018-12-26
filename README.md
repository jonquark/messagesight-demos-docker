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

### External LDAP

#### Demo environment details
     ---- To be added ----

#### Demo run steps
     ---- To be added ----


### OAuth authentication

#### Demo environment details
     ---- To be added ----

#### Demo run steps
     ---- To be added ----

### Subscription based Monitoring

#### Demo environment details
     ---- To be added ----

#### Demo run steps
To get monitoring statistics, use ms-mqtt-java-sample to subscribe to monitoring statistics:
```
$ ./target/ms-mqtt-java-sample -t "\$SYS/ResourceStatistics/+" -i MonitorClient -s tcp://127.0.0.1:16102

018-12-24 21:57:08.535 ServerURI: tcp://127.0.0.1:16102
2018-12-24 21:57:08.542 ClientID: MonitorClient
2018-12-24 21:57:08.542 Action: subscribe
2018-12-24 21:57:08.542 Topic: $SYS/ResourceStatistics/+
2018-12-24 21:57:08.596 cleanSession: true
Connected
2018-12-24 21:57:08.629 Client 'MonitorClient' subscribed to topic: '$SYS/ResourceStatistics/+' with QOS 0.
Subscription passed
2018-12-24 21:57:09.297 Message 1 received on topic '$SYS/ResourceStatistics/Memory':  { "Version":"5.0.0.0","NodeName":"9d2d549648d8","TimeStamp":"2018-12-25T03:57:09.327Z","ObjectType":"Memory", "MemoryTotalBytes":4294967296, "MemoryFreeBytes":3462549504, "MemoryFreePercent":81, "ServerVirtualMemoryBytes":2903527424, "ServerResidentSetBytes":826109952, "MessagePayloads":2097152, "PublishSubscribe":15728024, "Destinations":8920568, "CurrentActivity":16781312, "ClientStates":1572624 }
2018-12-24 21:57:09.297 Message 2 received on topic '$SYS/ResourceStatistics/Store':  { "Version":"5.0.0.0","NodeName":"9d2d549648d8","TimeStamp":"2018-12-25T03:57:09.330Z","ObjectType":"Store","DiskUsedPercent":59,"DiskFreeBytes":52350828937216,"MemoryUsedPercent":2,"MemoryTotalBytes":268434944,"Pool1TotalBytes":187904512,"Pool1UsedBytes":0,"Pool1UsedPercent":0,"Pool1RecordsLimitBytes":93952256,"Pool1RecordsUsedBytes":0,"Pool2TotalBytes":80530432,"Pool2UsedBytes":5378048,"Pool2UsedPercent":6 }
...
...
```

## Disconnected Client Notification demo

#### Demo environment details
     ---- To be added ----

#### Demo run steps
For this demo, you need to start three shell windows and run the following commands in order:

1. On window 1, start a subscriber to get disconnected client notifications
```
$ ./target/ms-mqtt-java-sample -t "\$SYS/DisconnectedClientNotification" -i MonitorNotifClient -s tcp://127.0.0.1:16102

Output:
2018-12-25 07:56:03.14 ServerURI: tcp://127.0.0.1:16102
2018-12-25 07:56:03.146 ClientID: MonitorNotifClient
2018-12-25 07:56:03.146 Action: subscribe
2018-12-25 07:56:03.146 Topic: $SYS/DisconnectedClientNotification
2018-12-25 07:56:03.148 This is a disconnected client notification subscriber.
2018-12-25 07:56:03.196 cleanSession: true
Connected
2018-12-25 07:56:03.224 Client 'MonitorNotifClient' subscribed to topic: '$SYS/DisconnectedClientNotification' with QOS 0.
Subscription passed
2018-12-25 07:57:07.517 Message 1 received on topic '$SYS/DisconnectedClientNotification':  {"ClientId":"GetNotifClient","MessagesArrived":[{"TopicString":"planets/earth","MessageCount":5}]}

```

2. On windows 2, start a durable subscriber and subscribe to topic "planets/earth"
```
$ ./target/ms-mqtt-java-sample -i "GetNotifClient" -t "planets/earth" -c false -a subscribe -n 5

Output:
2018-12-25 07:56:07.439 ServerURI: tcp://127.0.0.1:1883
2018-12-25 07:56:07.446 ClientID: GetNotifClient
2018-12-25 07:56:07.446 Action: subscribe
2018-12-25 07:56:07.446 Topic: planets/earth
This is a disconnected Subscriber test client.
2018-12-25 07:56:07.491 cleanSession: false
Connected
2018-12-25 07:56:07.54 Client 'GetNotifClient' subscribed to topic: 'planets/earth' with QOS 0.
Subscription passed
2018-12-25 07:56:11.87 Message 1 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:56:11.87 Message 2 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:56:11.87 Message 3 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:56:11.87 Message 4 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:56:11.87 Message 5 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:56:11.87 Received 5 messages.
Disconnected Test Client: Wakeup and resubscribe if wakeup file is set.
2018-12-25 07:57:22.046 ServerURI: tcp://127.0.0.1:1883
2018-12-25 07:57:22.046 ClientID: GetNotifClient
2018-12-25 07:57:22.046 Action: subscribe
2018-12-25 07:57:22.046 Topic: planets/earth
This is a disconnected Subscriber test client.
2018-12-25 07:57:22.046 cleanSession: false
Connected
2018-12-25 07:57:22.056 Client 'GetNotifClient' subscribed to topic: 'planets/earth' with QOS 0.
2018-12-25 07:57:22.056 Message 1 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:57:22.056 Message 2 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:57:22.057 Message 3 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:57:22.057 Message 4 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:57:22.057 Message 5 received on topic 'planets/earth':  I love IBM IoT MessageSight Server.
2018-12-25 07:57:22.057 Received 5 messages.

```
 
3. On window 3, start a publisher for to publish messages on topic "planets/earth"
```
$ ./target/ms-mqtt-java-sample -i "IBMIoT_disconPublisher" -t "planets/earth" -a publish -n 5

Output:
2018-12-25 07:56:11.786 ServerURI: tcp://127.0.0.1:1883
2018-12-25 07:56:11.792 ClientID: IBMIoT_disconPublisher
2018-12-25 07:56:11.792 Action: publish
2018-12-25 07:56:11.792 Topic: planets/earth
This is a disconnected Publisher test client.
Client 'IBMIoT_disconPublisher' ready to publish to topic: 'planets/earth' with QOS 0.
Client 'IBMIoT_disconPublisher' publishing to topic: 'planets/earth' with QOS 0.
0: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
1: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
2: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
3: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
4: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
Published 5 messages to topic planets/earth
Disconnected Test Client: Republish messages after 30 seconds
2018-12-25 07:56:41.873 ServerURI: tcp://127.0.0.1:1883
2018-12-25 07:56:41.873 ClientID: IBMIoT_disconPublisher
2018-12-25 07:56:41.873 Action: publish
2018-12-25 07:56:41.873 Topic: planets/earth
This is a disconnected Publisher test client.
Client 'IBMIoT_disconPublisher' ready to publish to topic: 'planets/earth' with QOS 0.
Client 'IBMIoT_disconPublisher' publishing to topic: 'planets/earth' with QOS 0.
0: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
1: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
2: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
3: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
4: Publishing "I love IBM IoT MessageSight Server." to topic planets/earth
Published 5 messages to topic planets/earth

```

## OAuth demo
   *** TBA ***
Client authentication using Liberty based OAuth server docker container.
   *** TBA ***

## SNMP demo

Client authentication using SNMP Trapd server docker container.

   *** TBA ***

## MessageSight HA demo

   *** TBA ***

## MessageSight Cluster demo

   *** TBA ***

## MessageSight MQ Connectivity demo

   *** TBA ***

## MessageSight Bridge demo

   *** TBA ***

