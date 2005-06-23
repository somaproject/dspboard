#!/usr/bin/env python

import pprint
import sys
import ParseDSP

if len(sys.argv)<2:
    raise ("\n\nToo few arguments\nusage: %s file1 [file]...\n\n" % (sys.argv[0]))

files = sys.argv[1:]  #list of files to parse
ffc = {}              #file function dictionary

for i in files:
    ffc = ParseDSP.get
