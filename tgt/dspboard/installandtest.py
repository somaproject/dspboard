#!/usr/bin/python
import os
import time
import echopingset
import pylab
ITERS = 1
for i in range(ITERS):
    dspbitfile = "/home/jonas/soma/bitfiles/dspboard.bit"
    os.system("python /home/jonas/soma/backplane/tgt/backplane/manual-boot-dsp.py %s 0" % dspbitfile)

    time.sleep(1)

    dsprom =  "/home/jonas/soma/bitfiles/dspboard.ldr"
    os.system("python dspboot.py %s 8 9 10 11" % dsprom)

    # now the test
    time.sleep(1)
    print "beginning ping test" 
    echopingset.pingset([8, 9, 10, 11])
    print "done" 

pylab.show()
