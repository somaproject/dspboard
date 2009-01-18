"""
Try and PING a DSPboard dspcontproc on the FPGA
(does not actually engage the DSP)

"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

whoping = [int(x) for x in sys.argv[1:]]
    
eio = NetEventIO("10.0.0.2")

for i in whoping:
    eio.addRXMask(0x09, i)

eio.start()

# Create event and set mask
e = Event()
e.src = eaddr.NETWORK
e.cmd =  0x08
e.data[0] = 0x1234
e.data[1] = 0x5678

ea = eaddr.TXDest()
for i in whoping:
    ea[i] = 1

eio.sendEvent(ea, e)

erx = eio.getEvents()
for q in erx:
    print q
eio.stop()

    
    
