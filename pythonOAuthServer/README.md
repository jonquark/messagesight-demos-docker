# OAuth server in Python

This project contains files to create and configure OAuth Server docker container 
that can be used with IBM IoT MessageSight to authenticate and authorize MQTT clients. 
Use this container for demos or tests only.

You can build and run the container on any operating environment that has
docker-ce (Docker Community Edition) environment set. For information on Docker Community Edition for your
operating environment, see [Docker Communit Edition](https://store.docker.com/search?q=Docker%20Community%20Edition&type=edition&offering=community).
Make sure that docker-ce deamon has minumum of 1 GiB of free memory for OAuth Server container.

The container exposes the following endpoints: <br>
Token endpoint:     https://127.0.0.1:5000/oauth2/endpoint/PythonOAuthProvider/token <br>
Authorize endpoint: https://127.0.0.1:5000/oauth2/endpoint/PythonOAuthProvider/authorize <br>

## Dependencies

The OAuth Server docker image is built from Python3 docker image. For detail on Python3 docker image refer to the following link:

https://hub.docker.com/_/python

## How to build oauthserver docker image?

Use the following command to build oauthserver docker image:
```
$ docker build --force-rm=true -t pyoauthserver:1.0 .
```

## How to run oauthserver docker container?

Use the following command to run oauthserver container:
```
$ docker run --net ms-service-net --ip 172.27.5.7 --publish 5000:5000 --memory 1G \
  --detach --interactive --tty --name pyoauthserver pyoauthserver:1.0
```

## Test OAuth server

You can use the following curl commands to test if OAuth server is working.

To authenticate a user use token endpoint:

```
$ curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d \
 "grant_type=password&client_id=pyOAuthTestClient&client_secret=testPassw0rd&username=spaceUser1&password=testPassw0rd" \
 https://127.0.0.1:5000/oauth2/endpoint/PythonOAuthProvider/token

```

The response from the OAuth server should look similar to the following response message:

```
{
  "access_token": "gRotiXHXwIUkNLyaWJGfeiDlUQCZiDbj",
  "expires_in": 1595538544,
  "refresh_token": "deQUVqepxXcZcljPrFaIxtoDnGDxWaGr",
  "scope": "",
  "token_type": "Bearer"
}

```

To authorize a resource using access_token returned by last command:

```
curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" https://127.0.0.1:5000/oauth2/endpoint/PythonOAuthProvider/authorize -d "token=gRotiXHXwIUkNLyaWJGfeiDlUQCZiDbj"
```

The response from the OAuth server should look similar to the following response message:
```
{"scope": "Group1,Group2", "client_id": "commaUser1", "active": true, "token_type": "Bearer", "exp": 1595538544}
```

## OAuth Configuration in MessageSight 

Use the following REST call to configure OAuth profile object in the MessageSight server:

POST https://<admin-endpoint-IP:Port>/ima/v1/configuration/

You can use the following object configuration data in the payload of POST method.
Substitute <ip_address_of_container_host> with the IP address of the container host.

```
{    
  "OAuthProfile": {
    "<NameOfOAuthProfile>": {
      "ResourceURL": "https://<ip_address_of_container_host>:5000/oauth2/endpoint/PythonOAuthProvider/authorize",
      "KeyFileName": "",
      "AuthKey": "access_token",
      "UserInfoURL": "https://<ip_address_of_container_host>:5000/oauth2/endpoint/PythonOAuthProvider/authori
ze",
      "UserInfoKey": "client_id",
      "GroupInfoKey": "scope",
      "GroupDelimiter": ",",
      "TokenSendMethod": "HTTPPost"
    } 
  }
}

Example:

$ curl -X POST -k https://127.0.0.1:9089/ima/v1/configuration -d \
  '{
    "OAuthProfile": {
      "TestOAuthProfile": {
        "ResourceURL": "https://127.0.0.1:5000/oauth2/endpoint/PythonOAuthProvider/authorize",
        "KeyFileName": "",
        "AuthKey": "access_token",
        "UserInfoURL": "https://127.0.0.1:5000/oauth2/endpoint/PythonOAuthProvider/authorize",
        "UserInfoKey": "client_id",
        "GroupInfoKey": "scope",
        "GroupDelimiter": ",",
        "TokenSendMethod": "HTTPPost"
      }
    }
  }'

```

For details on the REST call, refer to [Create or update an OAuth profile](https://www.ibm.com/support/knowledgecenter/en/SSWMAJ_2.0.0/com.ibm.ism.doc/Reference/SecurityCmd/cmd_create_update_oauth.html)

You can also use IBM MessageSight v5.0 WebUI to configure OAuthProfile object.

## Send Test Message

```
$ curl -k -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -d  "grant_type=password&client_id=pyOAuthTestClient&client_secret=testPassw0rd&username=commaUser1&password=testPassw0rd"  https://127.0.0.1:5000/oauth2/endpoint/PythonOAuthProvider/token
{
  "access_token": "fkADQXOdIkrUPbmLmjnIhDqGHpHtQgce",
  "expires_in": 1596721771,
  "refresh_token": "QWwAfcIhXMYtKDAssPSUvEiTXYmlFxwD",
  "scope": "",
  "token_type": "Bearer"
}
 
Get access_token from returned reponse and use as passowrd in the next command.

$ mosquitto_pub -h 127.0.0.1 -p 8883 -i "IBMIoTClient" -u "IMA_OAUTH_ACCESS_TOKEN" -t "test/Group1/topic" -q 2 -m "This is a Test Message" -P "fkADQXOdIkrUPbmLmjnIhDqGHpHtQgce"

```

