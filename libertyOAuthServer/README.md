# WAS-Liberty based OAuth server docker container for IBM IoT MessageSight testing

This project contains files to create and configure WAS-Liberty based OAuth Server docker container 
that can be used with IBM IoT MessageSight to authenticate MQTT clients. Use this container
in test environment only.

You can build and run the container on any operating environment that has
docker-ce (Docker Community Edition) environment set. For information on Docker Community Edition for your
operating environment, see [Docker Communit Edition](https://store.docker.com/search?q=Docker%20Community%20Edition&type=edition&offering=community).
Make sure that docker-ce deamon has minumum of 4 GiB of free memory for OAuth Server container.

## Dependencies

The OAuth Server docker image is built from developers version of IBM Websphere-Liberty 
docker image. For detail on Websphere-Liberty docker image refer to the following link:

https://hub.docker.com/_/websphere-liberty/


## Build, run or remove OAuth server docker image or container

The script *oauthserver.sh* can be used to build, run or remove OAuth server container.

By default OAuth server is configured to listen on all interfaces on the following ports:

```
Secured port: 9443
Non-secured port: 9080
```

The OAuth server is preconfigured to generate OAuth token and validate user accounts.
The user name of these accounts are MsgUser1 .. MsgUser5
The password of these user accounts are set to testPassw0rd

### How to build oauthserver docker image?

Use the following command to build oauthserver docker image:
```
$ ./oauthserver.sh build
```

### How to run oauthserver docker container?

Use the following command to run oauthserver container:
```
$ ./oauthserver.sh run
```
NOTES:
* OAuthe server container uses ms-service-net docker subnet created by script ../configureNetworks.sh
  and assigns IP address as 172.27.5.2 to oauthserver container.

### How to remove oauthserver docker container?

Use the following command to remove oauthserver container:
```
$ ./oauthserver.sh remove
```

### How to remove oauthserver docker image?

Use the following command to remove oauthserver docker image:
```
$ ./oauthserver.sh remove image
```

## Test OAuth server

You can use the following curl command to test if OAuth server is working.
Note that in the example, username is test3 and password is test3.
Substitute <ip_address_of_container_host> with the IP address of the container host. 

```
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d \
 "grant_type=password&client_id=wasLibertyClient&client_secret=testPassw0rd&username=MsgUser1&password=testPassw0rd" \
 https://<ip_address_of_container_host>:9443/oauth2/endpoint/DemoOAuthProvider/token

Example:
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d \
 "grant_type=password&client_id=wasLibertyClient&client_secret=testPassw0rd&username=MsgUser1&password=testPassw0rd" \
 https://127.0.0.1:9443/oauth2/endpoint/DemoOAuthProvider/token

```

The response from the OAuth server should look similar to the following response message:

```
{"access_token":"xSfhHOk3nVs7EJIZwqBJHJqJNxfMa0wjLmNuVdR6","token_type":"Bearer","expires_in":7776000,"scope":"","refresh_token":"J5lontTS0dGKfFpAZwIzn33hodqqd44ReOshqfaMZkKZPYg16C"}
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
      "ResourceURL": "http://<ip_address_of_container_host>:9080/oauth2/endpoint/DemoOAuthProvider/token",
      "KeyFileName": "",
      "AuthKey": "access_token",
      "UserInfoURL": "",
      "UserInfoKey": "",
      "GroupInfoKey": ""
    } 
  }
}

Example:

curl -X POST -k https://127.0.0.1:9089/ima/v1/configuration -d \
  '{
    "OAuthProfile": {
      "TestOAuthProfile": {
        "ResourceURL": "http://127.0.0.1:9080/oauth2/endpoint/DemoOAuthProvider/token",
        "KeyFileName": "",
        "AuthKey": "access_token",
        "UserInfoURL": "",
        "UserInfoKey": "",
        "GroupInfoKey": ""
      }
    }
  }'

```

For details on the REST call, refer to [Create or update an OAuth profile](https://www.ibm.com/support/knowledgecenter/en/SSWMAJ_2.0.0/com.ibm.ism.doc/Reference/SecurityCmd/cmd_create_update_oauth.html)

You can also use IBM MessageSight v5.0 WebUI to configure OAuthProfile object.


