import socket
import struct
import pylab
import numpy as n
import sys

s = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)

#s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
src = int(sys.argv[1])

s.bind(('', 4000 + src))
#s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)



CHANNUM = 4
N = 100
alldata = []
for i in xrange(N * CHANNUM):
    data,addr = s.recvfrom(1030)
    alldata.append(data)


# now unpack the data

offset = 10
tspikes = []
for d in alldata:
    seqnum = struct.unpack('>I', d[0:4])[0]
    chantyp = struct.unpack('>B', d[4])[0]
    chansrc = struct.unpack('>B', d[5])[0]
    chanlen = struct.unpack('>H', d[6:8])[0]
    somatime = struct.unpack('>Q', d[10:18])[0]
    print len(d), seqnum, chantyp, chansrc, chanlen, somatime

    chanos =  18
    wfs = []
##     for j in range (36):
##         print "%02d: " % j, 
##         for i in range(16):
##             print "%2.2X" % struct.unpack(">B", d[j * 16 + i]),
##         print

    for chan in range(4):
        chanos += 4 # valid

        filtid = struct.unpack('>I', d[chanos:chanos + 4])[0]
        chanos += 4 # filtid

        threshold = struct.unpack('>I', d[chanos:chanos + 4])[0]
        chanos += 4 # threshold

        print "%8.8X %8.8X" % (filtid, threshold)

        x = n.fromstring(d[chanos:(chanos + 32*4)], dtype=">i4")
        chanos += 32*4 
        wfs.append(x)
    tspikes.append((somatime, wfs))

pylab.subplot(4, 1, 1)
for i in range(4):
    pylab.subplot(4, 1, i + 1)
    for j in range(100):
        pylab.plot( tspikes[j][1][i] + 100*j)
pylab.show()
