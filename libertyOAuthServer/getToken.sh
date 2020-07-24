#!/bin/bash

curl -k -X POST https://127.0.0.1:9443/oauth2/endpoint/SampleProvider/token \
    -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
    -v -d \
    "grant_type=password&client_id=wasLibertyClient&client_secret=testPassw0rd&username=MsgUser1&password=testPassw0rd"

