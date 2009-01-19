"""
Ping the DSP on the DSPboard

The first argument is the deviceID of the DSP

"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

eio = NetEventIO("10.0.0.2")

dspboardaddrs =  [int(x) for x in sys.argv[1:]]

eio.addRXMask(0xF1, xrange(256))

eio.start()

# Create event and set mask
e = Event()
e.src = eaddr.NETWORK
e.cmd =  0xF0
e.data[0] = 0x1234

ea = eaddr.TXDest()
for d in dspboardaddrs:
    ea[d] = 1

eio.sendEvent(ea, e)

erx = eio.getEvents()
for q in erx:
    print q
eio.stop()

    
    
