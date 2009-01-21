"""
Uses the EchoProc on the DSP to measure our current RAM use

"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

eio = NetEventIO("10.0.0.2")

DSPBOARDADDR = int(sys.argv[1])

ECMD_ECHOPROC_MEMCHECK = 0xF8
ECMD_ECHOPROC_MEMCHECK_RESP = 0xF9
eio.addRXMask(ECMD_ECHOPROC_MEMCHECK_RESP, xrange(256))

eio.start()

# Create event and set mask
e = Event()
e.src = eaddr.NETWORK
e.cmd =  ECMD_ECHOPROC_MEMCHECK

ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1

eio.sendEvent(ea, e)

erx = eio.getEvents()
for q in erx:
    print q
eio.stop()

    
