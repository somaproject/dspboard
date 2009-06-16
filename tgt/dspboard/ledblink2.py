"""
Try and flash the DSPboard FPGA EVENT leds
"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

eio = NetEventIO("10.0.0.2")

eio.start()

CMD = 0x31
# Create event and set mask
N = 8

    
def getiset(j):
    return [q for q in range(j * 4 + 8, j*4 + 12)]

def setLED(addrs, stateon):
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  CMD
    if stateon:
        e.data[0] = 0xFFFF
    else:
        e.data[0] = 0x0000
    
    ea = eaddr.TXDest()
    for i in addrs:
        ea[i] = 1
    eio.sendEvent(ea, e)

lastj = 0
lastlastj = 0 
while(1) :
    for j in xrange(N):
        setLED(getiset(j), True)
        setLED(getiset(lastj), False)
        lastlastj = lastj
        lastj = j
        
        time.sleep(0.1)
        print "next", j
    time.sleep(0.2)
    for j in xrange(N-1, -1, -1):
        setLED(getiset(j), True)
        setLED(getiset(lastj), False)
        lastlastj = lastj
        lastj = j
        
        time.sleep(0.1)
        print "next", j
    time.sleep(0.2)

eio.stop()

    

    
