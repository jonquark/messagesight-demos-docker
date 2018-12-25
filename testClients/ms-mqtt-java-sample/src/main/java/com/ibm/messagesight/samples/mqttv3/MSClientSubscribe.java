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

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.*;
import org.eclipse.paho.client.mqttv3.internal.wire.*;

/**
 * This class contains the doSubscribe method for subscribing to MQTT topic messages. 
 * It also defines the necessary MQTT callbacks for asynchronous subscriptions.
 * 
 */
public class MSClientSubscribe implements MqttCallback {
   MSClientSample config = null;
   boolean done = false;
   int receivedcount = 0;
   int disconnTestSubscriber = 0;
   int disconnNotifSubscriber = 0;

   /**
    * Callback invoked when the MQTT connection is lost
    * 
    * @param e
    *           exception returned from broken connection
    * 
    */
   public void connectionLost(Throwable e) {
      config.println("Lost connection to " + config.serverURI + ".  " + e.getMessage());
      e.printStackTrace();
      System.exit(1);
   }

   /**
    * Synchronized method for indicating all messages received.
    * 
    * @param setDone
    *           optional Boolean parameter indicating all messages received.
    * 
    * @return Boolean flag
    */
   synchronized private boolean isDone(Boolean setDone) {
      if (setDone != null) {
         this.done = setDone;
      }
      return this.done;
   }

   /**
    * subscribe to messages published on the topic name
    * 
    * @param config
    *           MSClientSample instance containing configuration settings
    * 
    * @throws MqttException
    */
   public void doSubscribe(MSClientSample config) throws MqttException {

      this.config = config;

      MqttDefaultFilePersistence dataStore = null;
      if (config.persistence)
         dataStore = new MqttDefaultFilePersistence(config.dataStoreDir);

      if ( config.clientId.equals("GetNotifClient")) {
          disconnTestSubscriber = 1;
      }

      if ( config.clientId.equals("MonitorNotifClient")) {
          config.println("This is a disconnected client notification subscriber.");
          disconnNotifSubscriber = 1;
      }

      // MqttClient client = new MqttClient(config.serverURI, config.clientId, dataStore);
      MqttAsyncClient client = new MqttAsyncClient(config.serverURI, config.clientId, dataStore);
      client.setCallback(this);

      MqttConnectOptions options = new MqttConnectOptions();

      // Set CleanSession
      options.setCleanSession(config.cleanSession);
      config.println("cleanSession: " + config.cleanSession);

      if (config.password != null) {
         options.setUserName(config.userName);
         options.setPassword(config.password.toCharArray());
      }

      if (config.ssl == true) {
         config.println("SSL: enabled");

         Properties sslClientProps = new Properties();
         String keyStore = null;
         String keyStorePassword = null;
         String trustStore = null;
         String trustStorePassword = null;

         if ( config.sslProperty != null ) {
             try {
                 InputStream input = new FileInputStream("config.sslProperty");
                 Properties sslProps = new Properties();

                 sslProps.load(input);
                 keyStore = sslProps.getProperty("com.ibm.ssl.keyStore");
                 keyStorePassword = sslProps.getProperty("com.ibm.ssl.keyStorePassword");
                 trustStore = sslProps.getProperty("com.ibm.ssl.trustStore");
                 trustStorePassword = sslProps.getProperty("com.ibm.ssl.trustStorePassword");
             } catch (Exception e) {
                 config.println("Can not read SSL properties file");
             }
         } else {

             keyStore = System.getProperty("com.ibm.ssl.keyStore");
             if (keyStore == null)
                keyStore = System.getProperty("javax.net.ssl.keyStore");
    
             keyStorePassword = System.getProperty("com.ibm.ssl.keyStorePassword");
             if (keyStorePassword == null)
                keyStorePassword = System.getProperty("javax.net.ssl.keyStorePassword");
    
             trustStore = System.getProperty("com.ibm.ssl.trusStore");
             if (trustStore == null)
                trustStore = System.getProperty("javax.net.ssl.trustStore");
    
             trustStorePassword = System.getProperty("com.ibm.ssl.trusStorePassword");
             if (trustStorePassword == null)
                trustStorePassword = System.getProperty("javax.net.ssl.trustStorePassword");
        }

        config.println("keyStore: "+ keyStore);
        config.println("keyStorePasswd: "+ keyStorePassword);
        config.println("trustStore: "+ trustStore);
        config.println("trustStorePassword: "+ trustStorePassword);

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

     try {
         client.connect(options, null, new IMqttActionListener() {
             @Override
             public void onSuccess(IMqttToken iMqttToken) {
                 System.out.println("Connected");
             }

             @Override
             public void onFailure(IMqttToken iMqttToken, Throwable e) {
                 System.out.println("Failed to connect");
             }
         }).waitForCompletion();
     } catch (MqttException e) {
         config.println("Failed to connect");
     }

     // Subscribe to the topic. messageArrived() callback invoked when message received.
     try {
          IMqttToken token = client.subscribe(config.topicName, config.qos, null, new IMqttActionListener() {
              @Override
              public void onSuccess(IMqttToken iMqttToken) {
                  System.out.println("Subscription passed");
              }

              @Override
              public void onFailure(IMqttToken iMqttToken, Throwable e) {
                  System.out.println("Subscription failed");
              }
          });
      } catch(MqttException e) {
          config.println("Subscription failed. RC: " + e.getReasonCode());
          config.println("Disconnect client");
          client.disconnect();
          return;
      }

      config.println("Client '" + client.getClientId() + "' subscribed to topic: '" + config.topicName + "' with QOS " + config.qos + ".");

      // wait for messages to arrive before disconnecting
      try {
          while (!isDone(null)) {
              Thread.sleep(500);
          }
      } catch (InterruptedException e) {
          e.printStackTrace();
      }

      // Disconnect the client
      // Do not unsubscribe if this is a GetNotifClient (used for disconnected client notification)
      if ( disconnTestSubscriber == 0 ) 
          client.unsubscribe(config.topicName);
      client.disconnect();

      if (config.verbose)
         config.println("Subscriber disconnected.");
   }

   /**
    * Callback invoked when a message arrives.
    * 
    * @param topic
    *           the topic on which the message was received.
    * @param receivedMessage
    *           the received message.
    * @throws Exception
    *            the exception
    */
   public void messageArrived(String topic, MqttMessage receivedMessage) throws Exception {
      // increment count of received messages
      receivedcount++;

      config.println("Message " + receivedcount + " received on topic '" + topic + "':  " + new String(receivedMessage.getPayload()));

      // if all messages have been received then print message and set done
      // flag.
      if (config.count > 0 && receivedcount == config.count) {
         config.println("Received " + config.count + " messages.");
         isDone(true);
      }

      // If this is a disconnected notification processing client, set wakeup file
      if ( topic.equals("$SYS/DisconnectedClientNotification") ) {
          if ( disconnNotifSubscriber == 1 ) {
              /* touch a wakeup file */
              File file = new File("./tmp/wakeup");
              file.createNewFile();
          }
      }
      
      return;
   }

   public void deliveryComplete(IMqttDeliveryToken arg0) {
      // TODO Auto-generated method stub
      return;
   }

}
