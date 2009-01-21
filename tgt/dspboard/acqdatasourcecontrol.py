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
e.cmd =  0x40
e.data[0] = 0 # param 0 
e.data[1] = 0


ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1


eio.sendEvent(ea, e)
print "query sent, waiting for response"

erx = eio.getEvents()
for q in erx:
    print q


## # now we send the "set gain" event and wait for response
e = Event()
e.src = eaddr.NETWORK
e.cmd =  0x41
e.data[0] = 2
e.data[1] = 0xF
e.data[2] = 100



ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1

eio.sendEvent(ea, e)

print "Gain set event sent" 
erx = eio.getEvents()
for q in erx:
    print q


eio.stop()

    
    
