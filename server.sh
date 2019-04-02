#! /bin/bash
set -x


for ((idx=0; idx < $ARG_flows; idx++)); do
    nc -l -k $((1024+idx)) > /dev/null &
    PID_NC[$idx]="$!"
done

while sleep 1; do
    :
done
 
