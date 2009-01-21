"""
Query the DSP board for a lot of the EchoProc's status events, and
print the results


"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

ECMD_ECHOPROC_MEMCHECK = 0xF8
ECMD_ECHOPROC_MEMCHECK_RESP = 0xF9


ECMD_ECHOPROC_BENCHMARK = 0xF4
ECMD_ECHOPROC_BENCHMARK_RESP = 0xF4


dspboardaddrs = [int(x) for x in sys.argv[1:]]

eio = NetEventIO("10.0.0.2")

eio.addRXMask(ECMD_ECHOPROC_MEMCHECK_RESP, dspboardaddrs)
eio.addRXMask(ECMD_ECHOPROC_BENCHMARK_RESP, dspboardaddrs)

eio.start()

for d in dspboardaddrs:
    print "Device %02x ----------------------------------------" % (d,)
    # Create event and set mask
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  ECMD_ECHOPROC_MEMCHECK
    ea = eaddr.TXDest()
    ea[d] = 1

    eio.sendEvent(ea, e)

    erx = eio.getEvents()
    memsize = erx[0].data[1]
    print "heap use: %2.2fk" %  (memsize/ 1000.0 )

    # get the benchmarks:
    for i in range(3):
        eb = Event()
        eb.src = eaddr.NETWORK
        eb.cmd =  ECMD_ECHOPROC_BENCHMARK
        eb.data[0] = i
        eab = eaddr.TXDest()
        eab[d] = 1

        eio.sendEvent(eab, eb)

        erx = eio.getEvents()
        ein = erx[0]
        mostrecent = ein.data[1] * 2**16 + ein.data[2]
        max = ein.data[3] * 2**16 + ein.data[4]
        print "benchmark %i : latest: %d       max: %d" %(i, mostrecent, max)
        #print "heap use: %2.2fk" %  (memsize/ 1000.0 )
    
    
    print "-----------------------------------------------------"
    print
eio.stop()

    
    
