# This file is a work of a US government employee and as such is in the Public domain. 
# Simson L. Garfinkel, March 12, 2012 

import sys
server_version = open(sys.argv[1],"r").read().strip()
print "Server Version:",server_version
if(server_version == sys.argv[2]):
    print "\n\nVersion",sys.argv[1],"is already on the server.\n\n"
    sys.exit(-1)
sys.exit(0)
