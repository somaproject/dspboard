import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

somaip = sys.argv[1]

eio = NetEventIO(somaip)

DSPBOARDADDR = int(sys.argv[2])

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
e.data[1] = 0x1F # all five channels
e.data[2] = 00  # gain = 100
e.data[3] = 100


ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1

eio.sendEvent(ea, e)

print "Gain set event sent"
eventcnt = 0
while eventcnt < 5*3:
    erx = eio.getEvents()
    for q in erx:
        print q
        eventcnt += 1
    
# now we send the chan sel signal

e = Event()
e.src = eaddr.NETWORK
e.cmd =  0x41
e.data[0] = 4 # chansel
e.data[1] = 3 # tgt chan



ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1

eio.sendEvent(ea, e)

print "chan sel set event sent"
eventcnt = 0
while eventcnt < 1:
    erx = eio.getEvents()
    for q in erx:
        print q
        eventcnt += 1



eio.stop()

    
    
