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
    "flow_bw_spread": 0.5,
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
    --link-max=%(link_max)s
    --link-resolution=%(link_resolution)s

    --flow-bw-spread=%(flow_bw_spread)s
    --flow-bw-resolution=%(flow_bw_resolution)s

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
for name in ("link_min", "link_max", "flow_bw_spread"):
    kwargs[name] = float(kwargs[name])

flows = numpy.arange(kwargs["flows_min"], kwargs["flows_max"] + 1)
links = kwargs["link_min"] * 10**numpy.linspace(0, numpy.log10(kwargs["link_max"]/kwargs["link_min"]), kwargs["link_resolution"])
flowbws = numpy.linspace(1.-kwargs["flow_bw_spread"], 1.+kwargs["flow_bw_spread"], kwargs["flow_bw_resolution"])

flows2, links2, flowbws2 = numpy.meshgrid(flows, links, flowbws)

flowbws3 = links2 / flows2 * flowbws2

if kwargs.get("integers", False):
    flows2 = numpy.array(flows2, dtype=int)
    links2 = numpy.array(links2, dtype=int)
    flowbws3 = numpy.array(flowbws3, dtype=int)

if kwargs.get("stats"):
    print("Count:%s\nFlows: %s\nLinks: %s" % (flowbws2.shape[0]*flowbws2.shape[1]*flowbws2.shape[2], flows, links))
else:
    for flowidx in range(0, flowbws2.shape[0]):
        for linkidx in range(0, flowbws2.shape[1]):
            for linkbwidx in range(0, flowbws2.shape[2]):
                print("%s,%s,%s" % (links2[flowidx, linkidx, linkbwidx],
                                    flows2[flowidx, linkidx, linkbwidx],
                                    flowbws3[flowidx, linkidx, linkbwidx]))
            
