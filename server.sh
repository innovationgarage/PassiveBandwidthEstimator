#! /bin/bash
set -x


for ((idx=0; idx < $ARG_flows; idx++)); do
    nc -l -k $((1024+idx)) > /dev/null &
    PID_NC[$idx]="$!"
done

# Do this twice to make sure the client exits first
sleep $ARG_time
sleep $ARG_time
