#!/usr/bin/python

import sys
import urllib

CHUNK_SIZE = 1 * 1024 * 1024

try:
    gid = 37
    cid = int(sys.argv[1])
except:
    print "Usage: %s <category id> (the A/B test id, default 1)" % (sys.argv[0])
    sys.exit(1)

url = "http://games.cs.washington.edu/cgs/py/cse481d/getdata.py?gid=%d&cid=%d" % (gid, cid)
filename = "dump%d-%d.json" % (gid, cid)

fin = urllib.urlopen(url)
with open(filename, "w") as fout:
    while True:
        chunk = fin.read(CHUNK_SIZE)
        if not chunk: break
        fout.write(chunk)

