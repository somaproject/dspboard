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
dspaddrs = set()
delay = float(sys.argv[1])
for who in sys.argv[2:]:
    if '-' in who:
        # this is a range
        (startstr, endstr) = who.split("-")
        for r in range(int(startstr), int(endstr)+1):
            dspaddrs.add(r)
    else:
        dspaddrs.add(int(who))
if len(dspaddrs) == 0:
    raise Exception("Must specify at least one dsp board target")


eio.start()

CMD = 0xF2

# Create event and set mask
while(1) :
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  CMD
    e.data[0] = 0xFFFF

    ea = eaddr.TXDest()
    for i in dspaddrs:
        ea[i] = 1
    eio.sendEvent(ea, e)
    
#rint "on"
    time.sleep(delay)

    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  CMD
    e.data[0] = 0x0

    ea = eaddr.TXDest()
    for i in dspaddrs:
        ea[i] = 1
    eio.sendEvent(ea, e)
    #          print "off"
    time.sleep(delay)


eio.stop()

    

    
