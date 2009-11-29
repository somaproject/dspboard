import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

eio = NetEventIO("10.0.0.2")

stattgts = set()
for who in sys.argv[1:]:
    if '-' in who:
        # this is a range
        (startstr, endstr) = who.split("-")
        for r in range(int(startstr), int(endstr)+1):
            stattgts.add(r)
    else:
        stattgts.add(int(who))

for i in stattgts:
    eio.addRXMask(xrange(256), i)

eio.start()

# Create event and set mask
e = Event()
e.src = eaddr.NETWORK
e.cmd =  0x40 # query link status status
e.data[0] = 0 # param 0 , link status
e.data[1] = 0


ea = eaddr.TXDest()
for i in stattgts:
    ea[i] = 1

eio.sendEvent(ea, e)

stats = {}
erx = eio.getEvents()
for q in erx:
    stats[q.src] = q.data[1] 

for k, v in stats.iteritems():
    if v > 0:
        print "%02d :" % k, "UP"
    else:
        print "%02d :" % k, "DOWN"
    
eio.stop()

    
    
