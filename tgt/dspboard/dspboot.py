#!/usr/bin/python
"""
Boot a LDR file


"""
import sys
import os
import struct
import readline 
import sys
from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import time

class Block(object):
    def __init__(self, fid):

        self.flag = 0
        self.cnt = 0
        self.addr = 0
        
        self.header = fid.read(10)    
        self.updateHeader()

        self.fixHeader()
        
        self.updateHeader()
        if self.flag & 0x01 > 0:
            self.ZEROFILL = True
            self.block = "" 
        else:
            self.ZEROFILL = False
            self.block = fid.read(self.cnt)


        self.pflag = (self.flag >> 5) & 0xF

    def updateHeader(self):
        (self.addr, self.cnt, self.flag) = struct.unpack("<IIH", self.header)
        if self.flag & 0x8 > 0:
            self.INIT = True
        else:
            self.INIT = False

        if self.flag & 0x8000 > 0:
            self.FINAL = True
        else:
            self.FINAL = False

        
    def fixHeader(self):

        self.newflag = self.flag | 0x0020 # set PFLAG = 1
        
        self.newflag = self.flag & 0x7FFF # remove final
        self.header = self.header[:8] + struct.pack("<H", self.newflag)
    
            
    def setFinal(self):
        self.newflag = self.flag | 0x8000 # set FINAL
        self.header = self.header[:8] + struct.pack("<H", self.newflag)

        self.updateHeader()
        
        
def loadfiles():
    filename = sys.argv[1]    
    fid = file(filename)
    statinfo = os.stat(filename)
    filelen = statinfo[6]
    print filelen
    binobjs = []
    while(fid.tell() < filelen-1): # this is where i'd like the EOF
        block = Block(fid)
        binobjs.append(block)
        
    binobjs[-1].setFinal()

    res = []
    for b in binobjs:
        print "Block addr: %8.8X cnt: %8.8X INIT=%d, pflag=%d, zerofill=%d, final=%d" % (b.addr, b.cnt, b.INIT, b.pflag, b.ZEROFILL, b.FINAL)
        for i in range(min(len(b.block) , 20)):
            print "%2.2X" % ord(b.block[i]), 
        print
            
        res.append(b.header + b.block)

    return res

def chunk(string, maxlen):
    """
    return a string as a list of substrings of
    no more than maxlen bytes

    """
    l = len(string)
    chunkcnt  = l / maxlen + 1

    chunks = []
    for i in xrange(chunkcnt):
        chunks.append(string[i*maxlen:((i+1)*maxlen)])
    assert "".join(chunks) == string
    return chunks
    
eio = NetEventIO("10.0.0.2")

DSPBOARDADDR = 0x08
eio.addRXMask(xrange(256), DSPBOARDADDR)

eio.start()
EVENTRXCMD_DATABUF = 0x32
EVENTRXCMD_DATABUFTX = 0x33
EVENTRXCMD_DSPSPISS = 0x34
EVENTRXCMD_DSPSPIEN = 0x35
EVENTRXCMD_DSPRESET = 0x36

# Create event and set mask
e = Event()
e.src = eaddr.NETWORK
e.cmd =  EVENTRXCMD_DSPRESET
e.data[0] = 0x0000

ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1
eio.sendEvent(ea, e)
e = Event()

e.src = eaddr.NETWORK
e.cmd =  EVENTRXCMD_DSPRESET
e.data[0] = 0xFFFF

ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1
eio.sendEvent(ea, e)
#time.sleep(1)

# now make sure we are in control of the spi interface
e = Event()
e.src = eaddr.NETWORK
e.cmd =  EVENTRXCMD_DSPSPIEN
e.data[0] = 0xFFFF

ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1
eio.sendEvent(ea, e)
#time.sleep(1)

#sys.exit(1)
# deassert SPISS
e = Event()
e.src = eaddr.NETWORK
e.cmd =  EVENTRXCMD_DSPSPISS
e.data[0] = 0xFFFF

ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1
eio.sendEvent(ea, e)


e = Event()
e.src = eaddr.NETWORK
e.cmd =  EVENTRXCMD_DSPSPISS
e.data[0] = 0x0000

ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1
eio.sendEvent(ea, e)
time.sleep(1)

# load up the blocks and send

blocks = loadfiles()
blockpos = 0

for byteblock in blocks:
    MAXLEN = 512
    chunks = chunk(byteblock, MAXLEN)
    print "byteblock, len = ", len(byteblock), len(chunks), "chunks"
    cpos = 0
    for b in chunks:
        pos = 0
        while pos < len(b):
            bytes = b[pos:pos+2]

            words = struct.unpack(">H", bytes)

            e = Event()
            e.src = eaddr.NETWORK
            e.cmd =  EVENTRXCMD_DATABUF
            e.data[0] = words[0]

            ea = eaddr.TXDest()
            ea[DSPBOARDADDR] = 1
            eio.sendEvent(ea, e)

            pos += 2
        e = Event()
        e.src = eaddr.NETWORK
        e.cmd =  EVENTRXCMD_DATABUFTX
        e.data[0] = blockpos * 256 + cpos
        ea = eaddr.TXDest()
        
        ea[DSPBOARDADDR] = 1
        eio.sendEvent(ea, e)
        print "sent databuftx event, blockpos =%d,  block len = %d, chunk number %d" % (blockpos, len(b), cpos)
        erx = eio.getEvents()
        for q in erx:
            print q

        cpos += 1
    blockpos += 1
e = Event()
e.src = eaddr.NETWORK
e.cmd =  EVENTRXCMD_DSPSPISS
e.data[0] = 0xFFFF

ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1
eio.sendEvent(ea, e)

    
# Give DSP control of SPI interface
e = Event()
e.src = eaddr.NETWORK
e.cmd =  EVENTRXCMD_DSPSPIEN
e.data[0] = 0x0000

ea = eaddr.TXDest()
ea[DSPBOARDADDR] = 1
eio.sendEvent(ea, e)

eio.stop()



    

