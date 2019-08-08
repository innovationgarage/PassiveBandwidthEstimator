#! /bin/bash
set -x

tc qdisc add dev eth0 root netem $ARG_netem

ifconfig > /control/interfaces

tcpdump -i eth0 -w /control/dumpfile -C 10 &
PID_TCPDUMP="$!"

{
    pv --rate-limit $ARG_ratelimit0 < /dev/zero |
        nc server 1024
} &
PID_NC[0]="$!"
for ((idx=1; idx < $ARG_flows; idx++)); do
    {
        pv --rate-limit $ARG_ratelimit < /dev/zero |
            nc server $((1024+idx))
    } &
    PID_NC[$idx]="$!"
done

sleep $ARG_time
