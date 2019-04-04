#! /usr/bin/env python

import sys
import numpy

args = []
kwargs = {
    "flows-min": 2,
    "flows-max": 40,
    "link-min": 100,
    "link-max": 10000,
    "link-resolution": 20,
    "flow-bw-spread": 0.5,
    "flow-bw-resolution": 10,
}
for arg in sys.argv[1:]:
    if arg.startswith("--"):
        arg = arg[2:]
        argval = True
        if "=" in arg:
            arg, argval = arg.split("=", 1)
        kwargs[arg] = argval
    else:
        args.append(arg)

if kwargs.get("help"):
    print("""Usage:
generategrid.py OPTIONS

    --flows-min=%(flows-min)s
    --flows-max=%(flows-max)s

    --link-min=%(link-min)s
    --link-max=%(link-max)s
    --link-resolution=%(link-resolution)s

    --flow-bw-spread=%(flow-bw-spread)s
    --flow-bw-resolution=%(flow-bw-resolution)s

    --stats
      Output stats rather than the actual grid

    Output is CSV with columns linkbw,flows,flowbw
""" % kwargs)
    sys.exit(1)
    
for name in ("flows-min", "flows-max", "link-resolution", "flow-bw-resolution"):
    kwargs[name] = int(kwargs[name])
for name in ("link-min", "link-max", "flow-bw-spread"):
    kwargs[name] = float(kwargs[name])

flows = numpy.arange(kwargs["flows-min"], kwargs["flows-max"] + 1)
links = kwargs["link-min"] * 10**numpy.linspace(0, numpy.log10(kwargs["link-max"]/kwargs["link-min"]), kwargs["link-resolution"])
flowbws = numpy.linspace(1.-kwargs["flow-bw-spread"], 1.+kwargs["flow-bw-spread"], kwargs["flow-bw-resolution"])

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
            
