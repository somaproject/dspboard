
#!/usr/bin/python

from vhdltest import vhdltest
import unittest
import sys


suite = unittest.TestSuite()

vhdlTestCase = vhdltest.ModelVhdlSimTestCase

if len(sys.argv) > 1 :
    # run those from the command line
    for i in sys.argv[1:]:
        suite.addTest(vhdlTestCase(i))
        
else:
    # core components
    
    suite.addTest(vhdlTestCase("acqserial"))
    suite.addTest(vhdlTestCase("bootser"))
    suite.addTest(vhdlTestCase("datasport"))
    suite.addTest(vhdlTestCase("decodemux"))
    #suite.addTest(vhdlTestCase("decoder"))
    #suite.addTest(vhdlTestCase("devicemuxtx"))
    #suite.addTest(vhdlTestCase("dgranttest"))
    suite.addTest(vhdlTestCase("encodedata"))
    suite.addTest(vhdlTestCase("encodemux"))
    suite.addTest(vhdlTestCase("encodemuxintegrate"))
    #suite.addTest(vhdlTestCase("eventrx"))
    #suite.addTest(vhdlTestCase("eventtx"))
    suite.addTest(vhdlTestCase("evtendianrev"))
    #suite.addTest(vhdlTestCase("fibertx"))
    #suite.addTest(vhdlTestCase("proceventio"))
    #suite.addTest(vhdlTestCase("uartacqrx"))

    suite.addTest(vhdlTestCase("uartbyteout"))

runner = unittest.TextTestRunner()
runner.run(suite)
