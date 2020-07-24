#!/bin/bash

curl -k https://127.0.0.1:9443/oauth2/endpoint/SampleProvider/authorize \
    -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
    -v -d \
    "response_type=code&client_id=wasLibertyClient&client_secret=testPassw0rd&username=MsgUser1&password=testPassw0rd"

