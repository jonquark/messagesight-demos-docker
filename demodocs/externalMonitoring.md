# IBM IoT MessageSight v5 Demos
## Using docker containers

## Subscription based Monitoring

The IBM IoT MessageSight server publishes nonpersistent monitoring messages to fixed $SYS topics. An external application can subscribe to these topics to get monitoring statistics.

### Demo Environment details

To showcase this use case, following docker containers and test clients are used:

- imaserver (IBM IoT MessageSight server container)
- ms-mqtt-java-sample


### Demo Run steps

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

### IBM IoT MessageSight knowledge center references:

For more information, you can refer to the following links:

- [Monitoring by using an external application](https://www.ibm.com/support/knowledgecenter/SSWMAJ_5.0.0/com.ibm.ism.doc/Monitoring/admin00008_.html)
- [Viewing memory statistics by using an external application](https://www.ibm.com/support/knowledgecenter/SSWMAJ_5.0.0/com.ibm.ism.doc/Monitoring/admin00052.html)
- [Viewing topic monitoring statistics by using an external application](https://www.ibm.com/support/knowledgecenter/SSWMAJ_5.0.0/com.ibm.ism.doc/Monitoring/admin00041.html)
- [Viewing endpoint level statistics by using an external application](https://www.ibm.com/support/knowledgecenter/SSWMAJ_5.0.0/com.ibm.ism.doc/Monitoring/admin00040.html)
- [Viewing store statistics by using an external application](https://www.ibm.com/support/knowledgecenter/SSWMAJ_5.0.0/com.ibm.ism.doc/Monitoring/admin00050.html)





