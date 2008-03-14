"""
Try and PING the DSPboard
"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

eio = NetEventIO("10.0.0.2")

DSPBOARDADDR = 0x08
#eio.addRXMask(xrange(256), DSPBOARDADDR)
eio.addRXMask(xrange(256), 0xAB)

eio.start()

# Create event and set mask
## e = Event()
## e.src = eaddr.NETWORK
## e.cmd =  0x30
## e.data[0] = 0x1234
## e.data[1] = 0x5678

## ea = eaddr.TXDest()
## ea[DSPBOARDADDR] = 1
## eio.sendEvent(ea, e)

erx = eio.getEvents()
for q in erx:
    print q
eio.stop()

    
    

