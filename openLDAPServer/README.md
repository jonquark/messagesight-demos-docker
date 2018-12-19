# OpenLDAP docker container
## For IBM IoT MessageSight v5 Demos

This project contains files to create and configure open LDAP docker container 
that can be used as an external LDAP server for IBM IoT MessageSight v5 Demos.

You can build and run open LDAP container on any operating environment that has
docker-ce (Docker Community Edition) environment set. For information on Docker Community Edition for your
operating environment, see [Docker Communit Edition](https://store.docker.com/search?q=Docker%20Community%20Edition&type=edition&offering=community).
Make sure that docker-ce deamon has minumum of 2 GiB of free memory for open LDAP container.

To build and run open LDAP docker container, use openldapDocker.sh script.
This script will create the following docker image:
```
Name: openldap
Version: 1.0
```

By default open LDAP server is configured to listen on all interfaces. 
You can edit LDAP_URL variable in run.sh script to change interface address, 
before executing the script to build and run the container.

The openldap server is preconfigured to create a set of groups and users that
can be used in configured policies in IBM IoT MessageSight server:

```
Group: MsgGroup1   Users: MsgUser1, MsgUser2, MsgUser3
Group: MsgGroup2   Users: MsgUser1, MsgUser4, MsgUser5
```

The openldap server bind password is set to msDemoPassw0rd.
To change the password, edit the value of BINDPASSWD variable in *openldapDocker.sh*
script.

By default the user MsgUser1 ... MsgUser5 password is set to testPassw0rd.
To change the password, edit the value of USERPASSWD variable in *openldapDocker.sh*
script. Use *slappasswd* utility to create a password.

### How to build openldap docker image?

Use the following command to build openldap docker image:
```
$ ./openldap.sh build
```

### How to remove openldap docker image?

Use the following command to remove openldap docker image:
```
$ ./openldap.sh remove image
```

### How to run openldap docker container?

Use the following command to run openldap container:
```
$ ./openldap.sh run
```
NOTES:
* Openldap container uses ms-service-net docker subnet created by script ../configureNetworks.sh
  and assigns IP address as 172.27.5.1 to openldap container.
* Do not use openldap server immediately after executing this step to run the container.
  It takes approximately 90 seconds to complete internal setup and configuration.

### How to remove openldap docker container?

Use the following command to remove openladp container:
```
$ ./openldap.sh remove
```

## How to configure external LDAP Configuration in IBM IoT MessageSight?

Use the following REST call to configure external LDAP object in the MessageSight server:

POST http://<admin-endpoint-IP:Port>/ima/v1/configuration/

You can use the following object configuration data in the payload of POST method. Replace 
<host_ip_address_of_container_host> with the IP address of the container host.

```
{    
  "LDAP": {
    "URL": "ldap://<host_ip_address_of_container_host>",
    "BaseDN": "o=IBM",
    "BindDN": "cn=Manager,o=IBM",
    "BindPassword": "msDemoPassw0rd",
    "UserSuffix": "ou=users,ou=MessageSight,o=IBM",
    "GroupSuffix": "ou=groups,ou=MessageSight,o=ibm",
    "UserIdMap": "*:cn",
    "GroupIdMap": "*:cn",
    "GroupMemberIdMap": "member"
    "IgnoreCase": true,
    "Timeout": 10,
    "EnableCache": true,
    "MaxConnections": 10,
    "Enabled": true
  }
}
```

For details on the REST call, refer to [Create or update an LDAP server connection](https://www.ibm.com/support/knowledgecenter/en/SSWMAJ_5.0.0/com.ibm.ism.doc/Reference/SecurityCmd/cmd_create_update_LDAP.html).

You can also use IBM MessageSight WebUI to configure external LDAP object.


## Pre-configured Users and Groups in the open LDAP server

You can use the following users and groups for MessageSight messaging test:

```
User Name: MsgUser1
Password:  testPassw0rd
Member of Group: MsgGroup1
Member of Group: MsgGroup2


User Name: MsgUser2
Password:  testPassw0rd
Member of Group: MsgGroup1


User Name: MsgUser3
Password:  testPassw0rd
Member of Group: MsgGroup1


User Name: MsgUser4
Password:  testPassw0rd
Member of Group: MsgGroup2


User Name: MsgUser5
Password:  testPassw0rd
Member of Group: MsgGroup2

```

