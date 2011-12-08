#! /bin/bash
export LC=C
links=$(ldd $1 | cut -f2 | cut -d">" -f2 | cut -d"(" -f1)
packages=$(dpkg -S $links 2>/dev/null | cut -d":" -f1)
touch ./packages.txt
for i in $packages
do
    if [ ! "$(grep "$i" packages.txt)" ];  then
    	version=$(apt-cache policy $i | grep "Installed:" | cut -d" " -f4)
	echo "$i (>= $version )" >> packages.txt
    fi
done
