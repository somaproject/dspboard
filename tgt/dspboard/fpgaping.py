"""
Try and PING a DSPboard dspcontproc on the FPGA
(does not actually engage the DSP)

"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

pingtgts = set()
for who in sys.argv[1:]:
    if '-' in who:
        # this is a range
        (startstr, endstr) = who.split("-")
        for r in range(int(startstr), int(endstr)+1):
            pingtgts.add(r)
    else:
        pingtgts.add(int(who))
    
    
eio = NetEventIO("10.0.0.2")

for i in pingtgts:
    eio.addRXMask(0x09, i)

eio.start()

# Create event and set mask
e = Event()
e.src = eaddr.NETWORK
e.cmd =  0x08
e.data[0] = 0x1234
e.data[1] = 0x5678

ea = eaddr.TXDest()
for i in pingtgts:
    ea[i] = 1

eio.sendEvent(ea, e)

starttime = time.time()
PINGWAIT = 1.0
eventsrxed = []
while len(eventsrxed) < len(pingtgts):
    erx = eio.getEvents(blocking=False)
    eventsrxed += erx
    if time.time() > starttime + PINGWAIT:
        break; 
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

    
    
