import socket
import struct
from matplotlib import pyplot
import numpy as np
import sys

s = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)

#s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
src = int(sys.argv[1])

s.bind(('', 4064 + src))
#s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)



N = 100
alldata = []
for i in xrange(N):
    data,addr = s.recvfrom(1030)
    alldata.append(data)


for d in alldata:
    seqnum = struct.unpack('>I', d[0:4])[0]
    chantyp = struct.unpack('>B', d[4])[0]
    chansrc = struct.unpack('>B', d[5])[0]
    
    somatime = struct.unpack('>Q', d[6:14])[0]

    WAVE_DATA_VERSION = struct.unpack('>H', d[14:16])[0]

    sampratenum = struct.unpack(">I", d[16:20])[0]
    samprateden = struct.unpack(">I", d[20:24])[0]
    filtid= struct.unpack(">I", d[24:28])[0]
    selchan = struct.unpack(">H", d[28:30])[0]

    data = np.fromstring(d[30:], dtype=">i4")
    print data
    
    print seqnum, chantyp, chansrc,somatime, WAVE_DATA_VERSION, sampratenum, samprateden, filtid, selchan

    pyplot.plot(data)

pyplot.show()
