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
import java.sql.Timestamp;
import java.util.Random;

import org.eclipse.paho.client.mqttv3.*;

/**
 * Package Name: 
 * com.ibm.messagesight.samples.mqttv3
 * 
 * This package contains a client sample code to connect, publish and subscribe messages to
 * IBM IoT MessageSight Server, using Paho MQTTv3 classes. This sample consists of three classes: 
 * 
 * MSClientSample.java: Contains methods for argument parsing, and logging and utility functions.
 *
 * MSClientPublish.java: Contains methods specific to subscribing to messages published to an MQTT topic.
 * 
 * MSClientSubscribe.java: Contains methods specific to publishing messages to an MQTT topic.
 * 
 * For command line options, refer to function usage().
 *
 */


public class MSClientSample implements Runnable {

   /* NOTE:
    * Though this class implements Runnable to support execution in a separate thread,
    * a separate thread is not used in the main function. This is provided if users like
    * to customize the sample client.
    */

   final static int AT_MOST_ONCE = 0;
   final static int AT_LEAST_ONCE = 1;
   final static int EXACTLY_ONCE = 2;

   public static String progName = null;

   /**
    * Output the usage statement to standard out.
    * 
    * @param args
    *           The command line arguments passed into main().
    * @param comment
    *           An optional comment to be output before the usage statement
    */
   private void usage(String[] args, String comment) {
      System.err.println();
      if (comment != null) {
         System.err.println(comment);
         System.err.println();
      }
      System.err.println("USAGE: " + progName + " "
          + "[-i clientID] [-s serverURI] [-u userID] [-p password] [-a action] [-t topicName] " 
          + "[-m message] [-n count] [-w rate] [-q qos] [-c cleansession] [-r dataStore] "
          + "[-o logfileName] [-v] [-h]");
      System.err.println();
      System.err.println("where:\n\n"
           + " -i clientID \n"
           + "    Specifies the client id used for registering the client with the IBM IoT MessageSight \n"
           + "    This is an optional parameter. The default value is IBMIoTClient \n"
           + "\n" 
           + " -s serverURI \n"
           + "    Specifies the URI of the IBM IoT MessageSight Server. \n"
           + "    For non-TLS connection, use tcp://<ip address>:<port> \n"
           + "    For TLS connection, use ssl://<ip address>:<port> \n"
           + "    This is an optional parameter. The default value is tcp://127.0.0.1:1883/ \n"
           + "\n" 
           + " -u userID \n"
           + "    Specifies user ID for secure communications. \n"
           + "    This is an optional parameter. \n"
           + "\n" 
           + " -p password \n"
           + "    Specifies password of the user specified using -u option, for secure communications. \n"
           + "    This is an optional parameter. \n"
           + "\n" 
           + " -a action \n" 
           + "    Specifies action string. \n"
           + "    Valid values are publish and subscribe. \n"
           + "    This is an optional parameter. Default value is subscribe. \n"
           + "\n" 
           + " -t topicName \n" 
           + "    Specifies the name of the topic on which the messages are published or subscribed. \n" 
           + "    This is an optional parameter. The default topic name is /IoTSampleTopic \n"
           + "\n" 
           + " -m message \n" 
           + "    Specifies a string representing the message to be published. \n"
           + "    This is an optional parameter. \n"
           + "    The default message is \"I love IBM IoT MessageSight Server.\" \n"
           + "\n" 
           + " -n count \n" 
           + "    Specifies the number of times the specified message is to be published or subscribed. \n"
           + "    This is an optional parameter. The default count is 1. \n"
           + "    If set to 0, the client will publish messages or wait for messages to arrive, for ever \n"
           + "    till the process is killed. \n"
           + "\n" 
           + " -w rate \n" 
           + "    Specifies the rate at which messages are sent in units of messages/minute. \n"
           + "    This is an optional parameter. \n"
           + "    If count (-n option) is 0, and rate is not set, this parameter gets set to 12. \n"
           + "\n" 
           + " -q qos \n" 
           + "    Specifies the Quality of Service (QoS) level. \n"
           + "    The valid values are 0, 1, or 2. \n"
           + "    This is an optional parameter. The default value is 0. \n"
           + "\n" 
           + " -c cleansession \n"
           + "    Specifies a flag to indicate if server side session data should be removed when client disconnects. \n"
           + "    If this parameter is set to true, server will remove session data (a non-durable client). \n"
           + "    If this parameter is set to false, server will not remove session data (a durable client). \n"
           + "    This is an optional parameter. The default value is true. \n"
           + "\n" 
           + " -r dataStore \n"
           + "    Specifies data store directory. Setting this parameter enables persistence. \n"
           + "    This is an optional parameter. \n"
           + "\n" 
           + " -o logFileName \n"
           + "    Specifies log file name. \n"
           + "    This is an optional parameter. The default value is stdout. \n"
           + "\n" 
           + " -v Indicates verbose output \n"
           + "\n" 
           + " -h Prints usage statement \n"
           + "\n" 
           + "SSL Parameters that can be set using system properties: \n"
           + "\n"
           + "com.ibm.ssl.protocol:            TLSv1 \n"
           + "com.ibm.ssl.keyStore:            The name of the file that contains the KeyStore object. \n"
           + "                                 Example: /mydir/etc/key.p12 \n"
           + "com.ibm.ssl.keyStorePassword:    The password for the KeyStore object. \n"
           + "com.ibm.ssl.keyStoreType:        Type of key store. \n"
           + "                                 Example: PKCS12, JKS, JCEKS \n"
           + "com.ibm.ssl.keyStoreProvider:    Key store provider. \n"
           + "                                 Example: IBMJCE or IBMJCEFIPS. \n"
           + "com.ibm.ssl.trustStore:          The name of the file that contains the trustStore object. \n"
           + "com.ibm.ssl.trustStorePassword:  The password for the TrustStore object. \n"
           + "com.ibm.ssl.trustStoreType:      The type of KeyStore object. \n"
           + "                                 Example: keyStoreType. \n"
           + "com.ibm.ssl.trustStoreProvider:  Trust store provider. \n"
           + "                                 Example: IBMJCE or IBMJCEFIPS \n"
           + "com.ibm.ssl.enabledCipherSuites: List of ciphers to be enabled. \n"
           + "                                 Example: SSL_RSA_WITH_AES_128_CBC_SHA;SSL_RSA_WITH_3DES_EDE_CBC_SHA. \n"
           + "com.ibm.ssl.keyManager:          Algorithm to be used to instantiate a KeyManagerFactory object. \n" 
           + "                                 Example: IbmX509 or IBMJ9X509 \n" 
           + "com.ibm.ssl.trustManager:        Algorithm to be used to instantiate a TrustManagerFactory object. \n"
           + "                                 Example: PKIX or IBMJ9X509 \n"
           + "com.ibm.ssl.contextProvider:     Underlying JSSE provider.");
      System.err.println();
   }
   
   /**
    * The main method executes the client's run method.
    * @param args - Commandline arguments. See usage statement.
    */
   public static void main(String[] args) {
      /* Instantiate and run the client. */
      new MSClientSample(args).run();
   }

   public String action = "subscribe";
   public String clientId = "IBMIoTClient"; 
   public String userName = null;
   public String password = null;
   public int throttleWaitMSec = 0;
   public int count = 1;
   public String dataStoreDir = null;
   public String payload = "I love IBM IoT MessageSight Server.";
   public boolean persistence = false;
   public int qos = AT_MOST_ONCE;
   public boolean cleanSession = true;
   public String serverURI = null;
   public String topicName = "/IoTSampleTopic";
   public boolean ssl = false;
   public boolean verbose = false;
   public String sslProperty = null;

   /**
    * Instantiates a new MQTT client.
    */
   public MSClientSample(String[] args) {
      parseArgs(args);
   }

   /**
    * Parses the command line arguments passed into main().
    * 
    * @param args
    *           the command line arguments. See usage statement.
    */
   private void parseArgs(String[] args) {
      boolean showUsage = false;
      String comment = null;
      
      String cmdline = System.getProperty("sun.java.command");
      String[] cmdargs = cmdline.split(" ");
      progName = cmdargs[0];

      for (int i = 0; i < args.length; i++) {
         if ("-s".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            serverURI = args[i];
            if (serverURI.startsWith("tcp://")) {
               ssl = false;
            } else if (serverURI.startsWith("ssl://")) {
               ssl = true;
            } else {
               showUsage = true;
               comment = "Invalid Parameter:  " + args[i] + ".  serverURI must begin with either tcp:// or ssl://.";
               break;
            }
         } else if ("-a".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            action = args[i];
         } else if ("-i".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            clientId = args[i];
            if (clientId.length() > 23) {
               showUsage = true;
               comment = "Invalid Parameter:  " + args[i] + ".  The clientId cannot exceed 23 characters.";
               break;
            }
         } else if ("-m".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            payload = args[i];
         } else if ("-z".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            sslProperty = args[i];
         } else if ("-t".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            topicName = args[i];
         } else if ("-n".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            count = Integer.parseInt(args[i]);
         } else if ("-o".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            setfile(args[i]);
         } else if ("-r".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            dataStoreDir = args[i];
            persistence = true;
         } else if ("-v".equalsIgnoreCase(args[i])) {
            verbose = true;
         } else if ("-h".equalsIgnoreCase(args[i])) {
            showUsage = true;
            break;
         } else if ("-q".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            if ("0".equals(args[i])) {
               qos = AT_MOST_ONCE;
            } else if ("1".equals(args[i])) {
               qos = AT_LEAST_ONCE;
            } else if ("2".equals(args[i])) {
               qos = EXACTLY_ONCE;
            } else {
               showUsage = true;
               comment = "Invalid Parameter:  " + args[i];
               break;
            }
         } else if ("-c".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            if ("true".equalsIgnoreCase(args[i])) {
               cleanSession = true;
            } else if ("false".equalsIgnoreCase(args[i])) {
               cleanSession = false;
            } else {
               showUsage = true;
               comment = "Invalid Parameter:  " + args[i];
               break;
            }
         } else if ("-u".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            userName = args[i];
         } else if ("-p".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            password = args[i];
         } else if ("-w".equalsIgnoreCase(args[i]) && (i + 1 < args.length)) {
            i++;
            throttleWaitMSec = Integer.parseInt(args[i]);
         } else {
            showUsage = true;
            comment = "Invalid Parameter:  " + args[i];
            break;
         }
      }

      if (showUsage == false) {
         if (dataStoreDir == null)
            dataStoreDir = System.getProperty("java.io.tmpdir");

         if (clientId == null) {
            clientId = MqttClient.generateClientId();
            if (clientId.length() > 23) {
               // If the generated clientId is too long, then create one based on action and a
               // random number.
               clientId = String.format("%s_%.0f", action, new Random(99999));
            }
         }

         if (serverURI == null) {
            comment = "Missing required parameter: -s <serverURI>";
            showUsage = true;
         } else if (action == null) {
            comment = "Missing required parameter: -a publish|subscribe";
            showUsage = true;
         } else if (!("publish".equals(action)) && !("subscribe".equals(action))) {
            comment = "Invalid parameter: -a " + action;
            showUsage = true;
         } else if ((password != null) && (userName == null)) {
            comment = "Missing parameter: -u <userId>";
            showUsage = true;
         } else if ((userName != null) && (password == null)) {
            comment = "Missing parameter: -p <password>";
            showUsage = true;
         }
      }

      if (showUsage) {
         usage(args, comment);
         System.exit(1);
      }
   }

   /**
    * Primary MQTT client method that either publishes or subscribes messages on a topic
    */
   public void run() {

      try {
         if ("publish".equalsIgnoreCase(action)) {
            new MSClientPublish().doPublish(this);
         } else { // If action is not publish then it must be subscribe
            new MSClientSubscribe().doSubscribe(this);
         }
      } catch (Throwable e) {
         println("MqttException caught in MQTT sample:  " + e.getMessage());
         e.printStackTrace();
      }

      /*
       * close program handles
       */
         close();

      return;
   }

   private PrintStream stream = System.out;

   void setfile(String filename) {
      try {
         FileOutputStream fos = new FileOutputStream(filename);
         synchronized (stream) {
            stream = new PrintStream(fos);
         }
         if (verbose)
            println("Log sent to " + filename);

      } catch (Throwable e) {
         println("Log entries sent to System.out instead of " + filename);
      }
   }

   void println(String string) {
      synchronized (stream) {
         stream.println(new Timestamp(new java.util.Date().getTime()) + " " + string);
      }
   }

   void close() {
      synchronized (stream) {
         if (stream != System.out)
            stream.close();
      }
   }

}
