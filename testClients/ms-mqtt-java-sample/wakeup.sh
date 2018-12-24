#!/bin/bash

COUNT=0
while [ $COUNT -eq 0 ]
do
    if [ -f wakeup_client ]
    then
        COUNT=1
    else
        sleep 2
    fi
done

rm -f wakeup_client

./target/ms-mqtt-java-sample -s tcp://127.0.0.1:16102 -i testclient -t planets/earth  -a subscribe -c false -q 2 &


