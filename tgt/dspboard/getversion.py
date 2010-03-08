"""
Print the firmware version of the DSP firmware (not the FPGA firmware,
which conforms to the standard FPGA interface).

"""

import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import struct
import time

# field decoders
def print_name(evt):
    s = struct.pack("HHHH",
                    evt.data[1], evt.data[2], 
                    evt.data[3], evt.data[4])
    print "firmware name: ", s

def print_version(evt):
    print "version: %d.%d" % ( evt.data[1], evt.data[2])

def print_hash(evt):
    s = struct.pack("HHHH",
                    evt.data[1], evt.data[2], 
                    evt.data[3], evt.data[4])
    v = struct.unpack("L", s)[0]
    print "git sha-1 begins: %16.16x" % v

def print_build_time(evt):
    print evt
    
    x = evt.data[1] << 16 |  evt.data[2]
    print "build time:", time.asctime(time.localtime(x))

funcs = {8 : print_name,
         9 : print_version,
         10: print_hash,
         11: print_build_time}

    

somaip = sys.argv[1]

eio = NetEventIO(somaip)

DSPBOARDADDR = int(sys.argv[2])

ECMD_VERSION_QUERY = 0x04
eio.addRXMask(ECMD_VERSION_QUERY, DSPBOARDADDR)

eio.start()
for field in range(0, 4):
    # Create event and set mask
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  ECMD_VERSION_QUERY
    e.data[0] = (1 << 15) |  field
    

    ea = eaddr.TXDest()
    ea[DSPBOARDADDR] = 1


    eio.sendEvent(ea, e)

    erx = eio.getEvents()
    for q in erx:
        print q
        #funcs[field](q)

        
eio.stop()

    
    
