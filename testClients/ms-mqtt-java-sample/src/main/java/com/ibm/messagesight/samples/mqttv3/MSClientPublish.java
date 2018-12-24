/*
 *
 ********************************************************************************
 * Copyright (c) 2017-2018 IBM Corp.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *
 * The Eclipse Public License is available at
 *    http://www.eclipse.org/legal/epl-v10.html
 * and the Eclipse Distribution License is available at
 *   http://www.eclipse.org/org/documents/edl-v10.php.
 *
 ********************************************************************************
 *
 */

package com.ibm.messagesight.samples.mqttv3;

import java.io.FileOutputStream;
import java.io.PrintStream;
import java.util.Properties;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.*;

/**
 * This class contains the doPublish method for publishing messages to an MQTT topic. 
 * It also defines the necessary MQTT callbacks for asynchronous publishing.
 * 
 */
public class MSClientPublish implements MqttCallback {

   MSClientSample config = null;
   private PrintStream stream = System.out;

   /**
    * Callback invoked when the MQTT connection is lost
    * 
    * @param e
    *           exception returned from broken connection
    * 
    */
   public void connectionLost(Throwable e) {
      stream.println("Lost connection to " + config.serverURI + ".  " + e.getMessage());
      e.printStackTrace();
      System.exit(1);
   }

   /**
    * Callback invoked when message delivery complete
    * 
    * @param token
    *           same token that was returned when the messages was sent with the method MqttTopic.publish(MqttMessage)
    */
   public void deliveryComplete(IMqttDeliveryToken token) {
      if (config.verbose)
         stream.println("Message delivery complete.");

   }

   /**
    * Publish message to the specified topic
    * 
    * @param config
    *           MSClientSample instance containing configuration settings
    * 
    * @throws MqttException
    */
   public void doPublish(MSClientSample config) throws MqttException {

      this.config = config;

      MqttDefaultFilePersistence dataStore = null;
      if (config.persistence)
         dataStore = new MqttDefaultFilePersistence(config.dataStoreDir);

      MqttClient client = new MqttClient(config.serverURI, config.clientId, dataStore);
      client.setCallback(this);

      MqttConnectOptions options = new MqttConnectOptions();

      // set CleanSession true to automatically remove server data associated with the client id at
      // disconnect. In this sample the clientid is based on a random number and not typically
      // reused, therefore the release of client's server side data on disconnect is appropriate.
      options.setCleanSession(config.cleanSession);
      if (config.password != null) {
         options.setUserName(config.userName);
         options.setPassword(config.password.toCharArray());
      }

      if (config.ssl == true) {
         Properties sslClientProps = new Properties();

         String keyStore = System.getProperty("com.ibm.ssl.keyStore");
         if (keyStore == null)
            keyStore = System.getProperty("javax.net.ssl.keyStore");

         String keyStorePassword = System.getProperty("com.ibm.ssl.keyStorePassword");
         if (keyStorePassword == null)
            keyStorePassword = System.getProperty("javax.net.ssl.keyStorePassword");

         String trustStore = System.getProperty("com.ibm.ssl.trusStore");
         if (trustStore == null)
            trustStore = System.getProperty("javax.net.ssl.trustStore");

         String trustStorePassword = System.getProperty("com.ibm.ssl.trusStorePassword");
         if (trustStorePassword == null)
            trustStorePassword = System.getProperty("javax.net.ssl.trustStorePassword");

         if (keyStore != null)
            sslClientProps.setProperty("com.ibm.ssl.keyStore", keyStore);
         if (keyStorePassword != null)
            sslClientProps.setProperty("com.ibm.ssl.keyStorePassword", keyStorePassword);
         if (trustStore != null)
            sslClientProps.setProperty("com.ibm.ssl.trustStore", trustStore);
         if (trustStorePassword != null)
            sslClientProps.setProperty("com.ibm.ssl.trustStorePassword", trustStorePassword);

         options.setSSLProperties(sslClientProps);
      }

      // KeepAliveInterval is set to 0 to keep the connection from timing out
      options.setKeepAliveInterval(86400);

      client.connect(options);

      // Get an instance of the topic
      MqttTopic topic = client.getTopic(config.topicName);

      // Construct the message to publish
      MqttMessage message = new MqttMessage(config.payload.getBytes());
      message.setQos(config.qos);

      // The default retained setting is false.
      if (config.persistence)
         message.setRetained(true);

      stream.println("Client '" + client.getClientId() + "' ready to publish to topic: '" + config.topicName + "' with QOS " + config.qos + ".");
      long startTime = System.currentTimeMillis();

      for (int i = 0; i < config.count; i++) {
         if (config.verbose)
            stream.println(i + ": Publishing \"" + message + "\" to topic " + config.topicName);

         if (config.throttleWaitMSec > 0) {
            long currTime = System.currentTimeMillis();
            double elapsed = (double) (currTime - startTime);
            double projected = ((double) i / (double) config.throttleWaitMSec) * 1000.0;
            if (elapsed < projected) {
               double sleepInterval = projected - elapsed;
               try {
                  Thread.sleep((long) sleepInterval);
               } catch (InterruptedException e) {
                  e.printStackTrace();
               }
            }
         }
         // Publish the message
         MqttDeliveryToken token = topic.publish(message);
         if (i == 0)
            stream.println("Client '" + client.getClientId() + "' publishing to topic: '" + topic.getName() + "' with QOS " + message.getQos() + ".");

         // Wait until the message has been delivered to the server
         if (config.qos > 0)
            token.waitForCompletion();
      }

      // Disconnect the client
      client.disconnect();

      stream.println("Published " + config.count + " messages to topic " + config.topicName);

   }

   public void messageArrived(String arg0, MqttMessage arg1) throws Exception {
   }

}
