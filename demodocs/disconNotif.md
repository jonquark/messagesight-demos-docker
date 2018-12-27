# IBM IoT MessageSight v5 Demos
## Using docker containers

## Disconnected client notification

Disconnected client notifications can be used to notify disconnected clients that there are messages waiting on IBM IoT MessageSight Server.

### Demo Environment details

To showcase this use case, following docker containers and test clients are used:

- imaserver (IBM IoT MessageSight server container)
- ms-mqtt-java-sample - three instances of this test client


### Demo Run steps

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


### IBM IoT MessageSight knowledge center references:

For more information, you can refer to the following links:

- [Disconnected client notifications](https://www.ibm.com/support/knowledgecenter/SSWMAJ_5.0.0/com.ibm.ism.doc/Overview/ov00140_.html)
- [Configuring disconnected client notifications](https://www.ibm.com/support/knowledgecenter/SSWMAJ_5.0.0/com.ibm.ism.doc/Administering/ad00850_.html)


