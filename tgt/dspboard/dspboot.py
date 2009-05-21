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
EVENTRXCMD_DATABUF = 0x32
EVENTRXCMD_DATABUFTX = 0x33
EVENTRXCMD_DSPSPISS = 0x34
EVENTRXCMD_DSPSPIEN = 0x35
EVENTRXCMD_DSPRESET = 0x36

def reallysend(eio, ea, e):
    while True:
        try:
            eio.sendEvent(ea, e)
            break
        except IOError:
            pass
        
    
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

def main():

    dspaddrs = set()
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
    eio = NetEventIO("10.0.0.2")

    #DSPBOARDADDR = tgt
    for d in dspaddrs:
        eio.addRXMask(xrange(256), d)

    eio.start()

    ea = eaddr.TXDest()

    for d in dspaddrs:
        ea[d] = 1

    print "Asserting DSP reset" 
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  EVENTRXCMD_DSPRESET
    e.data[0] = 0x0000
    reallysend(eio, ea, e)

    print "Deasserting DSP reset" 
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  EVENTRXCMD_DSPRESET
    e.data[0] = 0xFFFF
    reallysend(eio, ea, e)

    print "Acquiring DSP SPI interface for FPGA" 
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  EVENTRXCMD_DSPSPIEN
    e.data[0] = 0xFFFF
    reallysend(eio, ea, e)

    print "Deasserting SPISS"
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  EVENTRXCMD_DSPSPISS
    e.data[0] = 0xFFFF
    reallysend(eio, ea, e)


    print "Reasserting SPISS"
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  EVENTRXCMD_DSPSPISS
    e.data[0] = 0x0000
    reallysend(eio, ea, e)

    time.sleep(1)

    # load up the blocks and send

    blocks = loadfiles()
    blockpos = 0

    for byteblock in blocks:
        MAXLEN = 1024
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
                e.data[1] = pos / 2

                ea = eaddr.TXDest()
                for d in dspaddrs:
                    ea[d] = 1

                reallysend(eio, ea, e) # idempotent 
                pos += 2
            e = Event()
            e.src = eaddr.NETWORK
            e.cmd =  EVENTRXCMD_DATABUFTX
            # this is the length 
            e.data[0] = pos/2
            # now the nonce
            e.data[1] = cpos * 256 + pos 
            ea = eaddr.TXDest()
            for d in dspaddrs:
                ea[d] = 1

            reallysend(eio, ea, e)
            print "sent databuftx event, blockpos =%d,  block len = %d, chunk number %d" % (blockpos, len(b), cpos)

            # we need to get events from everyone
            ecnt = 0
            while ecnt < len(dspaddrs):
                erx = eio.getEvents()
                for q in erx:
                    ecnt += 1
		    print "Heard back from ", q.src, q
            

            cpos += 1
        blockpos += 1
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  EVENTRXCMD_DSPSPISS
    e.data[0] = 0xFFFF

    ea = eaddr.TXDest()
    for d in dspaddrs:
        ea[d] = 1
    reallysend(eio, ea, e)


    # Give DSP control of SPI interface
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  EVENTRXCMD_DSPSPIEN
    e.data[0] = 0x0000

    ea = eaddr.TXDest()

    for d in dspaddrs:
        ea[d] = 1

    reallysend(eio, ea, e)

    time.sleep(1)
    # now send all of the UART settings
    e = Event()
    e.src = eaddr.NETWORK
    e.cmd =  0x37
    for d in dspaddrs:
        e.data[0] = d
        e.data[1] = d
        e.data[2] = d
        e.data[3] = d
        e.data[4] = d
        ea = eaddr.TXDest()
        ea[d] = 1

        reallysend(eio, ea, e)
        
    
    eio.stop()





if __name__ == "__main__":
    main()
