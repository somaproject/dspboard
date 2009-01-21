"""
Dump the DSPboard's echoproc counter information
(for benchmarking)


"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

eio = NetEventIO("10.0.0.2")
DSPBOARDADDR = int(sys.argv[1])

eio.addRXMask([0xF4], DSPBOARDADDR)

eio.start()

CMD = 0xF4
# Create event and set mask
N = 8
for i in xrange(4):
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  CMD
    e.data[0] = i
    ea = eaddr.TXDest()
    ea[DSPBOARDADDR] = 1
    eio.sendEvent(ea, e)

    # now wait for response
    erx = eio.getEvents()
    for q in erx:
        print i, ":", q


eio.stop()

    

    
