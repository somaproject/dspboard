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

def setparse(args):
    pingtgts = set()
    for who in args:
        if '-' in who:
            # this is a range
            (startstr, endstr) = who.split("-")
            for r in range(int(startstr), int(endstr)+1):
                pingtgts.add(r)
        else:
            pingtgts.add(int(who))
    return pingtgts

class FPGAPing(object):
    def __init__(self, somaIP, tgts):
        self.eio = NetEventIO(somaIP)
        self.pingtgts = set(tgts)
        
        for i in self.pingtgts:
            #self.eio.addRXMask(0x09, i)
            self.eio.addRXMask(xrange(256), xrange(1, 70))
            self.eio.addRXMask(xrange(256), xrange(80, 256))
        self.eio.start()
        
    def ping(self):
        
        # Create event and set mask
        e = Event()
        e.src = eaddr.NETWORK
        e.cmd =  0x08
        e.data[0] = 0x1234
        e.data[1] = 0x5678

        ea = eaddr.TXDest()
        for i in self.pingtgts:
            ea[i] = 1

        self.eio.sendEvent(ea, e)

        starttime = time.time()
        PINGWAIT = 1.0
        eventsrxed = []
        while len(eventsrxed) < len(self.pingtgts):
            erx = self.eio.getEvents(blocking=False)
            if erx != None:
                for eias in erx:
                    print eias
                eventsrxed += erx
            if time.time() > starttime + PINGWAIT:
                break

        rxset = set()
        for e in eventsrxed:
            rxset.add(e.src)

        missing =  self.pingtgts.difference(rxset)
        return (rxset, missing)
    
    def stop(self):
        self.eio.stop()
        
if __name__ == "__main__":
    
    tgts = setparse(sys.argv[1:])
    fp = FPGAPing("10.0.0.2", tgts)
    cnt = 5
    for i in range(cnt):
        rxset, missing = fp.ping()

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
        time.sleep(0.5)
    fp.stop()
