#!/bin/bash
day=$(date  +%d)
month=$(date +%m)
year=$(date +%Y)

############################
#The userfriendly.org comic#
############################
ufie_datecode="$year$month$day"
cd /tmp/
ufie_base=http://ars.userfriendly.org/cartoons/?id="$ufie_datecode"
ufie_img=$(wget $ufie_base -O- 2>/dev/null | grep "SRC=\"http://www.userfriendly.org/cartoons/archives/")


############################
#        PHD.com           #
############################
phd_base=http://www.phdcomics.com/comics.php
phd_img=$(wget $phd_base -O- 2>/dev/null | grep "http://www.phdcomics.com/comics/archive/" | cut -d\" -f4)


############################
#      Penny Arcade        #
############################
pa_base_url=http://www.penny-arcade.com
pa_url=$pa_base_url/comic/$(date +%Y)/$(date +%-m)/$(date +%-d)
pa_img=$pa_base_url$(wget $pa_url -O- 2>/dev/null | grep simplebody | cut -d\" -f4)


############################
#          XKCD            #
############################

xkcd_base_url=http://xkcd.com
xkcd_img=$(wget $xkcd_base_url -O- 2>/dev/null | grep "<img src=\"http://imgs.xkcd.com/comics/")



############################
# Cyanide and happiness    #
############################

cah_base_url=http://www.explosm.net/comics/
cah_img=$(wget $cah_base_url -O- 2>/dev/null | grep "<img alt=\"Cyanide and Happiness, a daily webcomic\" src=\"http://www.explosm.net/db/files/" | cut -d"<" -f51)
############################
#      theWAREHOUSE        #
############################
wh_baseurl=http://www.warehousecomic.com/
wh_img=$wh_baseurl$(wget $wh_baseurl -O- 2>/dev/null | grep "<img src=\"comic/theWAREHOUSE_comic_" | cut -d\" -f2)

############################
#       chainsawsuit       #
############################
chainsaw=http://chainsawsuit.com
chainsaw_img=$(wget $chainsaw -O- 2>/dev/null | grep "<img id=\"comic\"" | cut -d\" -f12)

############################
#   FULL FRONTAL NERDITY   # 
############################
ffn=http://nodwick.humor.gamespy.com/ffn/
ffn_img=$(wget $ffn -O- 2>/dev/null | grep "http://nodwick.humor.gamespy.com/ffn/strips/" | cut -d"<" -f4)

############################
# amazing super powers     #
############################
asp=http://www.amazingsuperpowers.com/
asp_img=$(wget $asp -O- 2>/dev/null | grep "<img src=\"COMIC" | cut -d\" -f2)

###########################
#   not concentrated      #
###########################
nfcc=http://nfccomic.com/
nfcc_img=$nfcc$(wget $nfcc -O- 2>/dev/null | grep "<img border=\"0\" src=\"comics/" | cut -d\" -f8)


echo "<html><body>" $ufie_img "<br>"  $phd_img " <br> <img src=\""$pa_img\""><br>"$xkcd_img"<br><"$cah_img "<br> <img src=\""$wh_img"\"><br><img src=\""$chainsaw$chainsaw_img"\"><br><"$ffn_img "<br><img src=\""$asp$asp_img"\"><br><img src=\""$nfcc_img"\"></body></html>"
