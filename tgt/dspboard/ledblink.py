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
eio.addRXMask(xrange(256), DSPBOARDADDR)

eio.start()

# Create event and set mask
while(1) :
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  0x31
    e.data[0] = 0xFFFF

    ea = eaddr.TXDest()
    ea[DSPBOARDADDR] = 1
    eio.sendEvent(ea, e)
    print "on"
    time.sleep(1)

    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  0x31
    e.data[0] = 0x0

    ea = eaddr.TXDest()
    ea[DSPBOARDADDR] = 1
    eio.sendEvent(ea, e)
    print "off"
    time.sleep(1)


eio.stop()

    

    
