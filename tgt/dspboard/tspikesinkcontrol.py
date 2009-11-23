"""
Debug tspike sink control. By default, all channels are affected.

"""
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time
from optparse import OptionParser

ECMD_QUERY = 0x43
ECMD_SET = 0x44  
ECMD_RESPONSE = 0x13

PARAM_THRESHOLD = 1
PARAM_FILTER = 2


parser = OptionParser()
parser.add_option("-q", "--query",
                  action="store_true", dest="query", default=False,
                  help = "Query the status")
parser.add_option("-t", "--set-threshold",
                  dest="threshold", help ="Set the threshold to this mV")


(options, args) = parser.parse_args()
# args are the non-captured arguments

devices = [int(x) for x in args]


if options.query:
    eio = NetEventIO("10.0.0.2")

    thresholds = {}
    
    for d in devices:
        eio.addRXMask(ECMD_RESPONSE, d)

    eio.start()
    for chan in range(4):
        e = Event()
        e.src = eaddr.NETWORK
        e.cmd =  ECMD_QUERY
        e.data[0] = PARAM_THRESHOLD
        e.data[1] = chan 

        ea = eaddr.TXDest()
        for d in devices:
            ea[d] = 1
        eio.sendEvent(ea, e)

        erx = eio.getEvents()
        for e in erx:
            if e.cmd == ECMD_RESPONSE and e.data[0] == PARAM_THRESHOLD:
                if e.src not in thresholds:
                    thresholds[e.src] = {}
                val = int(e.data[2]) << 16 | e.data[3]
                thresholds[e.src][e.data[1]] = float(val)/1e9 * 1e3 # in mv
    eio.stop()

    for d in thresholds:
        print "Device ", d, " thresholds ----------------------------------"
        for c in thresholds[d]:
            print "  chan %d : %f mV" % (c, thresholds[d][c])
    
if options.threshold:
    
    eio = NetEventIO("10.0.0.2")

    for d in devices:
        eio.addRXMask(ECMD_RESPONSE, d)

    eio.start()

    val_v = float(options.threshold) / 1e3
    val_nv = val_v * 1e9
    val = int(val_nv)
    print "val =", val, val_v
    for chan in range(4):
        e = Event()
        e.src = eaddr.NETWORK
        e.cmd =  ECMD_SET
        e.data[0] = PARAM_THRESHOLD
        e.data[1] = chan
        e.data[2] = val >> 16 
        e.data[3] = val & 0xFFFF
        print e
        ea = eaddr.TXDest()
        for d in devices:
            ea[d] = 1

        eio.sendEvent(ea, e)

