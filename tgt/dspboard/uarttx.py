"""
Set the UART ID of the DSPboard


"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

eio = NetEventIO("10.0.0.2")

DSPBOARDADDR = int(sys.argv[1])

eio.addRXMask(xrange(256), DSPBOARDADDR)

eio.start()

# Create event and set mask
e = Event()
e.src = eaddr.NETWORK
e.cmd =  0x37
e.data[0] = DSPBOARDADDR
e.data[1] = DSPBOARDADDR
e.data[2] = DSPBOARDADDR
e.data[3] = DSPBOARDADDR
e.data[4] = DSPBOARDADDR

ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1

eio.sendEvent(ea, e)

eio.stop()

    
    
