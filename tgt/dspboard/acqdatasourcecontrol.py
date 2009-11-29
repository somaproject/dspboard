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
e.cmd =  0x40 # query link status status
e.data[0] = 0 # param 0 , link status
e.data[1] = 0


ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1


eio.sendEvent(ea, e)
print "acq link status query sent, waiting for response"

erx = eio.getEvents()
for q in erx:
    print q
if erx[0].data[1] == 1:
    print "Link status: UP"
else:
    print "Link status: DOWN"


## # now we send the "set gain" event and wait for response
e = Event()
e.src = eaddr.NETWORK
e.cmd =  0x41
e.data[0] = 2
e.data[1] = 0xF # all four channels
e.data[2] = 00  # gain = 100
e.data[3] = 100


ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1

eio.sendEvent(ea, e)

print "Gain set event sent"
eventcnt = 0
while eventcnt < 12:
    erx = eio.getEvents()
    for q in erx:
        print q
        eventcnt += 1
    

eio.stop()

    
    
