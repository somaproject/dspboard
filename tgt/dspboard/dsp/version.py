import os
import math
import time
import sys
from jinja2 import Template
from subprocess import Popen, PIPE

gitcmd ='git log HEAD^..HEAD --format="%H"'

GITHASH = Popen(["git", "log", "HEAD^..HEAD", '--format="%H"'],
                stdout=PIPE).communicate()[0]

HASHSUB = int(GITHASH[1:17], 16)

TIME = int(math.floor(time.time()))

infile = sys.argv[1]
outfile = sys.argv[2]

template = Template(file(infile).read())
s = template.render(BUILDTIME = TIME,
                    HASHSUB = HASHSUB)
file(outfile, 'w').write(s)

