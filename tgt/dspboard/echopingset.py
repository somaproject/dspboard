"""
repeatedly ing the DSP on the DSPboard

The first argument is the deviceID of the DSP

"""
import sys
import numpy as n
import pylab

from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

def pingset(dspboardaddrs):
    eio = NetEventIO("10.0.0.2")

    eio.addRXMask(0xF1, xrange(256))

    eio.start()

    # Create event and set mask
    N = 40
    x = n.zeros(N)
    for i in range(N):
        e = Event()
        e.src = eaddr.NETWORK
        e.cmd =  0xF0
        e.data[0] = 0x1234

        ea = eaddr.TXDest()
        for d in dspboardaddrs:
            ea[d] = 1

        eio.sendEvent(ea, e)
        erx = eio.getEvents()
        x[i] =  len(erx)    
    eio.stop()
    pylab.figure()
    pylab.hist(x)



if __name__ == "__main__":
    
    dspboardaddrs =  [int(x) for x in sys.argv[1:]]
    
    pingset(dspboardaddrs)
    pylab.show()
