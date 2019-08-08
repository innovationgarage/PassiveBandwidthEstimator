#! /usr/bin/env python

import sys
import os
import numpy

args = []
kwargs = {
    "flows_min": 2,
    "flows_max": 40,
    "link_min": 100,
    "link_max": 10000,
    "link_resolution": 20,
    "flow_bw0_min": 0.0,
    "flow_bw0_max": 0.5,
    "flow_bw0_resolution": 10,
    "flow_bw_min": 0.5,
    "flow_bw_max": 1.5,
    "flow_bw_resolution": 10,
}
for name, value in os.environ.items():
    if not name.startswith("ARG_"): continue
    kwargs[name[len("ARG_"):]] = value
for arg in sys.argv[1:]:
    if arg.startswith("--"):
        arg = arg[2:]
        argval = True
        if "=" in arg:
            arg, argval = arg.split("=", 1)
        kwargs[arg.replace("-", "_")] = argval
    else:
        args.append(arg)

if kwargs.get("help"):
    print("""Usage:
generategrid.py OPTIONS

    --flows-min=%(flows_min)s
    --flows-max=%(flows_max)s

    --link-min=%(link_min)s
      Link minimum bandwidth is in kbit.
    --link-max=%(link_max)s
      Link maximum bandwidth is in kbit.
    --link-resolution=%(link_resolution)s
      Number of different link bandwidths to generate

    --flow-bw-min=%(flow_bw_min)s
    --flow-bw-max=%(flow_bw_max)s
      Range of cross traffic flow bandwidth to generate. Fraction of link bandwidth: 0.5 means 0.5*linkbw
    --flow-bw-resolution=%(flow_bw_resolution)s
      Number of different cross traffic flow bandwidths to generate.

    --flow-bw0-min=%(flow_bw_min)s
    --flow-bw0-max=%(flow_bw_max)s
      Range of flow bandwidth to generate. Fraction of link bandwidth: 0.5 means from 0.5*linkbw
    --flow-bw0-resolution=%(flow_bw_resolution)s
      Number of different flow bandwidths to generate.

    --stats
      Output stats rather than the actual grid

Output is CSV with columns linkbw,flows,flowbw

Any OPTIONS can also be given as environment variables with their
names prefixed with ARG_, e.g.

  export ARG_flows_min=%(flows_min)s

""" % kwargs)
    sys.exit(1)
    
for name in ("flows_min", "flows_max", "link_resolution", "flow_bw_resolution"):
    kwargs[name] = int(kwargs[name])
for name in ("link_min", "link_max", "flow_bw_min", "flow_bw_max", "flow_bw0_min", "flow_bw0_max"):
    kwargs[name] = float(kwargs[name])

flows = numpy.arange(kwargs["flows_min"], kwargs["flows_max"] + 1)
linkbws = kwargs["link_min"] * 10**numpy.linspace(0, numpy.log10(kwargs["link_max"]/kwargs["link_min"]), kwargs["link_resolution"])
flowbws = numpy.linspace(kwargs["flow_bw_min"], kwargs["flow_bw_max"], kwargs["flow_bw_resolution"])
flowbw0s = numpy.linspace(kwargs["flow_bw0_min"], kwargs["flow_bw0_max"], kwargs["flow_bw0_resolution"])

if kwargs.get("stats"):
    print("Count:%s\nLink bw: %s\nXT flows: %s\nXT bw: %s\nFlow bw: %s" % (
        len(linkbws) * len(flows) * len(flowbws) * len(flowbw0s),
        ','.join(str(i) for i in linkbws),
        ','.join(str(i) for i in flows),
        ','.join(str(i) for i in flowbws),
        ','.join(str(i) for i in flowbw0s)))
else:
    for linkbw in linkbws:
        for flownr in flows:
            for flowbw in flowbws:
                for flowbw0 in flowbw0s:
                    print("%s,%s,%s,%s" % (
                        int(linkbw),
                        int(flownr),
                        int(linkbw / (flownr-1) * flowbw),
                        int(linkbw * flowbw0)
                    ))
