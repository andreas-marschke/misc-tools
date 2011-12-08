#! /bin/bash
export LC=C
file=$(sed s/\-I/"\n"/g $1)
packages=$(dpkg -S $file 2>/dev/null | cut -d":" -f1)
for i in $packages
do
    if [ ! "$(grep "$i" packages.txt)" ];  then
    	version=$(apt-cache policy $i | grep "Installed:" | cut -d" " -f4)
	echo "$i (>= $version )" >> packages.txt
    fi
done
   
