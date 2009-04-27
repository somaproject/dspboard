"""
repeatedly ing the DSP on the DSPboard

The first argument is the deviceID of the DSP

"""
import sys


from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

def debug(dspboardaddrs):
    eio = NetEventIO("10.0.0.2")

    eio.addRXMask(0x38, dspboardaddrs)
    
    eio.start()
    print "Sending to ", dspboardaddrs
    
    # Create event and set mask
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  0x38
    
    for d in dspboardaddrs:
        ea = eaddr.TXDest()
        ea[d] = 1
        eio.sendEvent(ea, e)
        print "sending", e
        erx = eio.getEvents()
        print erx[0]
    eio.stop()


if __name__ == "__main__":
    
    dspboardaddrs =  [int(x) for x in sys.argv[1:]]
    
    debug(dspboardaddrs)
