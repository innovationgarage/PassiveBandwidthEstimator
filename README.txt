Goal: To implement the algorithm in [Available Bandwidth Estimation
from Passive TCP Measurements using the Probe Gap
Model](https://ieeexplore.ieee.org/document/8264826) in an open source
passive bandwidth estimation tool.

= Tools =

* [Network link emulation](http://man7.org/linux/man-pages/man8/tc-netem.8.html)

= Code =

    docker exec -it bandwidthmeasure_h1_1 /bin/bash
      tc qdisc add dev eth0 root netem rate 100kbit
      iperf -d -t 10 -c h2

    docker exec -it bandwidthmeasure_h2_1 /bin/bash
      iperf -s

    tcpdump -i eth0 -w dumpfile -C 10

    sudo apt install libpcap0.8-dev libpcap0.8
    # pip install pypcap
    pip install pypcapfile
