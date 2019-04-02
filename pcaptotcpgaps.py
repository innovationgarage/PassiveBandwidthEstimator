import pcapfile.savefile
import numpy
import sys

with open(sys.argv[1], "rb") as f:
    d = pcapfile.savefile.load_savefile(f, layers=3, verbose=True)

    packets = numpy.zeros(len(d.packets), dtype=[("timestamp", int),
                                                 ("stream", int),
                                                 ("direction", bool),
                                                 ("seqnum", int),

                                                 ("ack", bool),
                                                 ("acknum", int),

                                                 ("src", "<S15"),
                                                 ("dst", "<S15"),
                                                 ("src_port", int),
                                                 ("dst_port", int)])

    streams = {}
    next_streamid = 0

    for idx, packet in enumerate((packet for packet in d.packets
                                  if packet.packet.type == 2048 and packet.packet.payload.p == 6)):            
        src = (packet.packet.payload.src,
               packet.packet.payload.payload.src_port)
        dst = (packet.packet.payload.dst,
               packet.packet.payload.payload.dst_port)

        streamname = tuple(sorted((src, dst)))
        if streamname not in streams:
            streams[streamname] = next_streamid
            next_streamid += 1
        streamid = streams[streamname]
        direction = src == streamname[0]
        
        packets[idx]["timestamp"] = packet.timestamp
        packets[idx]["stream"] = streamid
        packets[idx]["direction"] = direction
        packets[idx]["seqnum"] = packet.packet.payload.payload.seqnum
        packets[idx]["ack"] = packet.packet.payload.payload.ack
        packets[idx]["acknum"] = packet.packet.payload.payload.acknum
        packets[idx]["src"] = packet.packet.payload.src
        packets[idx]["src_port"] = packet.packet.payload.payload.src_port
        packets[idx]["dst"] = packet.packet.payload.dst
        packets[idx]["dst_port"] = packet.packet.payload.payload.dst_port
        
    numpy.savez_compressed(sys.argv[2], packets=packets[:idx+1])
