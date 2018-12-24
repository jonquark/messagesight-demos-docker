# WAS-Liberty based OAuth server docker container for IBM IoT MessageSight testing

This project contains files to create and configure WAS-Liberty based OAuth Server docker container 
that can be used with IBM IoT MessageSight to authenticate MQTT clients. Use this container
in test environment only.

You can build and run the container on any operating environment that has
docker-ce (Docker Community Edition) environment set. For information on Docker Community Edition for your
operating environment, see [Docker Communit Edition](https://store.docker.com/search?q=Docker%20Community%20Edition&type=edition&offering=community).
Make sure that docker-ce deamon has minumum of 4 GiB of free memory for OAuth Server container.

## Pre-requisite

You need WAS Liberty profile package. You can download the package using the following link:

https://developer.ibm.com/wasdev/downloads/#asset/runtimes-wlp-javaee8


## Build OAuth server docker container

Copy downloaded WAS Liberty image *wlp-javaee8-18.0.0.3.zip* in ../pkgs directory.

To build OAuth Server docker container, use script *oauthServer.sh*.

```
$ ./oauthServer.sh build
```

By default OAuth server is configured to listen on all interfaces on the following ports:

```
Secured port: 9443
Non-secured port: 9080
```

The OAuth server is preconfigured to generate OAuth token and validate user accounts.
The user name of these accounts are MsgUser1 .. MsgUser5
The password of these user accounts are set to testPassw0rd

## Run OAuth server docker container

To run container:
```
$ ./oauthServer.sh run
```

## Remove OAuth server container and docker image

To remove any exiting oAuth server container and docker image:
```
$ ./oauthServer.sh remove
```

## Test OAuth server

You can use the following curl command to test if OAuth server is working.
Note that in the example, username is test3 and password is test3.
Substitute <ip_address_of_container_host> with the IP address of the container host. 

```
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
 -d "grant_type=password&client_id=LibertyRocks&client_secret=AndMakesConfigurationEasy&username=test3&password=test3" \
 https://<ip_address_of_container_host>:9443/oauth2/endpoint/DemoProvider/token
```

The response from the OAuth server should look similar to the following response message:

```
{"access_token":"XmrTondwbiUmTlR5zYo2gJE4XGnVUlVRtlaeHxxp","token_type":"Bearer","expires_in":7776000,"scope":"","refresh_token":"dvnAhvLwYiB9WYC6uksCqyNsaaZETHkEGE13upPjX2EwQEOdmX"}
```

## OAuth Configuration in MessageSight 

Use the following REST call to configure OAuth profile object in the MessageSight server:

POST http://<admin-endpoint-IP:Port>/ima/v1/configuration/

You can use the following object configuration data in the payload of POST method.
Substitute <ip_address_of_container_host> with the IP address of the container host.

```
{    
  "OAuthProfile": {
    "<NameOfOAuthProfile>": {
      "ResourceURL": "http://<ip_address_of_container_host>:9080/oauth2/endpoint/DemoProvider/token",
      "KeyFileName": "",
      "AuthKey": "access_token",
      "UserInfoURL": "",
      "UserInfoKey": "",
      "GroupInfoKey": ""
    } 
  }
}
```

For details on the REST call, refer to [Create or update an OAuth profile](https://www.ibm.com/support/knowledgecenter/en/SSWMAJ_2.0.0/com.ibm.ism.doc/Reference/SecurityCmd/cmd_create_update_oauth.html)

You can also use IBM MessageSight v2.0 WebUI to configure OAuthProfile object.


