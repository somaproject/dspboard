#!/usr/bin/python

import os

jtagprog = "/home/jonas/XC3Sprog/xc3sprog"
jtagpos = 1


#os.system(jtagprog + " %d" % jtagpos + ' 0x03 "00 80"')
#os.system(jtagprog + " %d" % jtagpos + ' 0x03 "00 00"')

# then dump
res = []
for i in xrange(100):
    os.system(jtagprog + " %d" % jtagpos + ' 0x03 "%2.2X 00"' % i)
    r= os.popen(jtagprog + " %d" % jtagpos + ' 0x02 "00 00 00 00"')
    rbytes= r.read().split()
    
    res.append(int(rbytes[0], 16))
    
for i in xrange(len(res)):
    print "%03d : %2.2X" % (i, res[i])
    

