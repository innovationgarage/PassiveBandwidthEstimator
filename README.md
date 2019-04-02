Goal: To implement the algorithm in [Available Bandwidth Estimation
from Passive TCP Measurements using the Probe Gap
Model](https://ieeexplore.ieee.org/document/8264826) in an open source
passive bandwidth estimation tool.

## Tools

* [Network link emulation](http://man7.org/linux/man-pages/man8/tc-netem.8.html)

## Code

This repository currently contains two tools:

# trafficsimulator.sh

This script sets up two docker containers connected by a network link,
runs tc-netem on this link, rate limiting it and then runs a number of
netcat sessions attempting to pipe data at some defined rate over the
network, all while dumping packets sent and received using tcpdump.

    ./trafficsimulator.sh OPTIONS

      --client=./client.sh
      --server=./server.sh
      --flows=5
      --ratelimit=10M
      --netem="rate 100kbit"

      --time=60s

The output is placed in the file "dumpfile".

# pcaptotcpgaps.py

This script reads a tcpdump / libpcap savefile and produces an numpy
npz file containing time, src ip/port, dst ip/port, ack, acknum and
seqnum of all tcp packages, as well as a generated tcp stream id
integer assigned to each src/dst ip/port pairs.

    ./pcaptotcpgaps.py dumpfile gaps.npz
