# IBM MessageSight MQTT Java Client Sample

This package contains a client sample code to connect to IBM IoT MessageSight server and,
publish messages on an MQTT topic or subscribe to an MQTT Topic. This project is dependent
Paho MQTTv3 classes.

## To build
Use the following commands to build:
```
$ mvn clean
$ mvn package
```

## To run
Use the following command to run:
```
$ ./target/ms-mqtt-java-sample [-i clientID] [-s serverURI] [-u userID] [-p password] 
        [-a action] [-t topicName] [-m message] [-n count] [-w rate] [-q qos] 
        [-c cleansession] [-r dataStore] [-o logfileName] [-v] [-h]
```

Where:
<pre>
-i clientID
   Specifies the client id used for registering the client with the IBM IoT MessageSight Server
   This is an optional parameter. The default value is IBMIoTClient

-s serverURI
   Specifies the URI of the IBM IoT MessageSight Server.
   For non-TLS connection, use tcp://<ip address>:<port>
   For TLS connection, use ssl://<ip address>:<port>
   This is an optional parameter. The default value is tcp://127.0.0.1:1883/

-u userID
   Specifies user ID for secure communications.
   This is an optional parameter.

-p password
   Specifies password of the user specified using -u option, for secure communications.
   This is an optional parameter.

-a action
   Specifies action string.
   Valid values are publish and subscribe.
   This is an optional parameter. Default value is subscribe.

-t topicName
   Specifies the name of the topic on which the messages are published or subscribed.
   This is an optional parameter. The default topic name is /IoTSampleTopic

-m message
   Specifies a string representing the message to be published.
   This is an optional parameter. The default message is "I love IBM IoT MessageSight Server."

-n count
   Specifies the number of times the specified message is to be published or subscribed.
   This is an optional parameter. The default count is 1.
   If set to 0, the client will publish messages or wait for messages to arrive, for ever
   till the process is killed.

-w rate
   Specifies the rate at which messages are sent in units of messages/minute.
   This is an optional parameter.
   If count specified using -n option is 0, and rate is not set, this parameter gets set to 12.

-q qos
   Specifies the Quality of Service (QoS) level.
   The valid values are 0, 1, or 2.
   This is an optional parameter. The default value is 0.

-c cleansession
   Specifies a flag to indicate if server side session data should be removed when client disconnects.
   If this parameter is set to true, server will remove session data (a non-durable client).
   If this parameter is set to false, server will not remove session data (a durable client).
   This is an optional parameter. The default value is true.

-r useDataStore
   Specifies data store directory. Setting this parameter enables persistence.
   This is an optional parameter.

-o logFileName
   Specifies log file name.
   This is an optional parameter. The default value is stdout.

-v Indicates verbose output

-h Prints usage statement


The following SSL Parameters can be set using system properties:

com.ibm.ssl.protocol:            TLSv1
com.ibm.ssl.keyStore:            The name of the file that contains the KeyStore object.
                                 Example: /mydir/etc/key.p12
com.ibm.ssl.keyStorePassword:    The password for the KeyStore object.
com.ibm.ssl.keyStoreType:        Type of key store.
                                 Example: PKCS12, JKS, JCEKS
com.ibm.ssl.keyStoreProvider:    Key store provider.
                                 Example: IBMJCE or IBMJCEFIPS.
com.ibm.ssl.trustStore:          The name of the file that contains the trustStore object.
com.ibm.ssl.trustStorePassword:  The password for the TrustStore object.
com.ibm.ssl.trustStoreType:      The type of KeyStore object.
                                 Example: keyStoreType.
com.ibm.ssl.trustStoreProvider:  Trust store provider.
                                 Example: IBMJCE or IBMJCEFIPS
com.ibm.ssl.enabledCipherSuites: List of ciphers to be enabled.
                                 Example: SSL_RSA_WITH_AES_128_CBC_SHA;SSL_RSA_WITH_3DES_EDE_CBC_SHA.
com.ibm.ssl.keyManager:          Algorithm to be used to instantiate a KeyManagerFactory object.
                                 Example: IbmX509 or IBMJ9X509
com.ibm.ssl.trustManager:        Algorithm to be used to instantiate a TrustManagerFactory object.
                                 Example: PKIX or IBMJ9X509
com.ibm.ssl.contextProvider:     Underlying JSSE provider.
                                 Example: IBMJSSE2 or SunJSSE
</pre>


## Example to publish a message
```
./target/ms-mqtt-java-sample -s tcp://127.0.0.1:1883 -i testclient -t planets/earth  -m "Test Message" -a publish
```

## Example to subscribe to messages
```
./target/ms-mqtt-java-sample -s tcp://127.0.0.1:1883 -i testclient -t planets/earth  -a subscribe
```



