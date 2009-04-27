"""
Ping the DSP on the DSPboard

The first argument is the deviceID of the DSP

"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

eio = NetEventIO("10.0.0.2")

pingtgts = set()
for who in sys.argv[1:]:
    if '-' in who:
        # this is a range
        (startstr, endstr) = who.split("-")
        for r in range(int(startstr), int(endstr)+1):
            pingtgts.add(r)
    else:
        pingtgts.add(int(who))

for i in pingtgts:
    eio.addRXMask(xrange(256), i)
eio.addRXMask(xrange(256), xrange(1, 0x4c))


eio.start()

# Create event and set mask
e = Event()
e.src = eaddr.NETWORK
e.cmd =  0xF0
e.data[0] = 0x1234

ea = eaddr.TXDest()
for i in pingtgts:
    ea[i] = 1

eio.sendEvent(ea, e)

starttime = time.time()
PINGWAIT = 1.0
eventsrxed = []
while len(eventsrxed) < len(pingtgts):
    erx = eio.getEvents(blocking=False)
    if erx != None:
        eventsrxed += erx
    if time.time() > starttime + PINGWAIT:
        break
eio.stop()

rxset = set()

for e in eventsrxed:
    rxset.add(e.src)
missing =  pingtgts.difference(rxset)
print "Heard from",
for r in rxset:
    print r,
print

print "Did not hear from:",

if len(missing) == 0:
    print "None",
else:
    for m in missing:
        print m,
print
for r in eventsrxed:
    print r
    
    
## ea = eaddr.TXDest()
## for d in pingtgts:
##     ea[d] = 1

## eio.sendEvent(ea, e)

## erx = eio.getEvents()
## for q in erx:
##     print q
## eio.stop()

    
    
