docker exec -it bandwidthmeasure_h1_1 /bin/bash
  tc qdisc add dev eth0 root netem rate 100kbit
  iperf -d -t 10 -c h2

docker exec -it bandwidthmeasure_h2_1 /bin/bash
  iperf -s
