#!/bin/sh
#gksudo "aptitude -y install libpng3 libtiff4 cupsys alien"
cd /tmp
echo "Fetching drivers from Canon Australia"
wget http://download.canon.com.au/bj/i250linux/bjfilteri250-2.3-0.i386.rpm
wget http://download.canon.com.au/bj/i250linux/bjfiltercups-2.3-0.i386.rpm

