import socket
import struct
import pylab
import sys

s = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)

#s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

SRC = int(sys.argv[1])
s.bind(('', 4128 + SRC))
#s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

CHANNUM = 4
N = 10
alldata = []
for i in xrange(N * CHANNUM):
    data,addr = s.recvfrom(1030)
    alldata.append(data)


# now unpack the data

offset = 16 + 4
chansrcpos = 14

words = [[], [], [], []]
for d in alldata:
    chansrc = struct.unpack('>h', d[chansrcpos:chansrcpos+2])[0]
    print "%4.4X" % chansrc
    l = float(len(d[offset:]))/4
    chanwords = []
    for i in xrange(int(l)):
        s = struct.unpack('>i',d[offset + i *4: offset + (i+1)*4])[0]
        #print "%8.8X" % s
        chanwords.append(s)
    words[chansrc].extend(chanwords)
print words[0]
for i, w in enumerate(words):
    pylab.subplot( CHANNUM, 1, i+1)
    pylab.plot(w)

pylab.show()
