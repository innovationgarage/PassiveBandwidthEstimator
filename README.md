Goal: To implement the algorithm in [Available Bandwidth Estimation
from Passive TCP Measurements using the Probe Gap
Model](https://ieeexplore.ieee.org/document/8264826) in an open source
passive bandwidth estimation tool.

## Tools

* [Network link emulation](http://man7.org/linux/man-pages/man8/tc-netem.8.html)

## Code

This repository currently contains a set of tools to investigate
network behaviour over bandwidth limited links by simulating links
between docker containers:

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

# Cluster tools

The above scripts can be run over a range of parameters, possibly
parallelized over a cluster of machines using GNU parallel. This repo
cintains two scripts to ease in doing this. If you run docker swarm,
you might want to combine these with
[Ubuntucluster](https://github.com/innovationgarage/ubuntucluster). In
that case it is important that the data directories (input and output)
has the same mount point paths both on the hosts and inside the docker
containers.

Academic tradition requires you to cite works you base your article on.
When using programs that use GNU Parallel to process data for publication
please cite:

  O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
  ;login: The USENIX Magazine, February 2011:42-47.

This helps funding further development; AND IT WON'T COST YOU A CENT.
If you pay 10000 EUR you should feel free to use GNU Parallel without citing.


## gridsearch.sh

This script runs trafficsimulator.sh multiple times with different
parameters, possibly on a cluster of machines.

    ./gridsearch.sh OPTIONS
    
      --outdir=../data
      --repository=docker-repo-host:port/

      --flows-min=2
      --flows-max=40

      --link-min=100
        Link minimum bandwidth is in kbit.
      --link-max=10000
        Link maximum bandwidth is in kbit.
      --link-resolution=20
        Number of different link bandwidths to generate

      --flow-bw-spread=0.5
        Range of total flow bandwidth to generate. Fraction of link bandwidth: 0.5 means from 0.5*linkbw to 1.5*linkbw
      --flow-bw-resolution=10
        Number of different flow bandwidths to generate.

The output tcpdump dumpfiles will be placed in subdirectories of
outdir named "linkbw,flows,flowbw".

## gridpcaptotcpgaps.sh

Convert a directory tree of tcpdump dumpfiles to an equally structured
directory tree of numpy npz files using pcaptotcpgaps.py.

    ./gridpcaptotcpgaps.sh OPTIONS

      --indir=../data
      --outdir=../pgaps
