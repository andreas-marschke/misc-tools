#! /bin/bash

whereto=/home/andreas/devel/snipporama/shell_scripts/comic
file=$(wget -O-  http://www.myglobalip.com 2>/dev/null | grep "<h2>" |  cut -d":" -f2)

echo ${file:1:${#file}-6} 

