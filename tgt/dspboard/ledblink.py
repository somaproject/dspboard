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

DSPBOARDADDRS = [int(x) for x in sys.argv[1:]]
eio.addRXMask(xrange(256), 8)

eio.start()

CMD = 0xF2

# Create event and set mask
while(1) :
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  CMD
    e.data[0] = 0xFFFF

    ea = eaddr.TXDest()
    for i in DSPBOARDADDRS:
        ea[i] = 1
    eio.sendEvent(ea, e)
    print "on"
    time.sleep(1)

    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  CMD
    e.data[0] = 0x0

    ea = eaddr.TXDest()
    for i in DSPBOARDADDRS:
        ea[i] = 1
    eio.sendEvent(ea, e)
    print "off"
    time.sleep(1)


eio.stop()

    

    
