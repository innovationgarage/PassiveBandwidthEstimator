#! /bin/bash
set -x

tc qdisc add dev eth0 root netem $ARG_netem

tcpdump -i eth0 -w /control/dumpfile -C 10 &
PID_TCPDUMP="$!"

for ((idx=0; idx < $ARG_flows; idx++)); do
    {
        pv --rate-limit $ARG_ratelimit < /dev/zero |
            nc h2 $((1024+idx))
    } &
    PID_NC[$idx]="$!"
done

while sleep 1; do
    :
done
 
