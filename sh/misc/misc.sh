###
# substring removal
#
### From the beginning
# ${PARAMETER#PATTERN}
# ${PARAMETER##PATTERN}


var="This is a test"
echo ${var#* }
-> is a test

### From the end
# ${PARAMETER%PATTERN}
# ${PARAMETER%%PATTERN}

var="This is a test"
echo ${var% *}
-> This is a

### Pfadnamen abschneiden

pfad="/home/usr/verz"  # bash
echo ${pfad#/*/*/*}
-> verz

# mit awk

ls -l $pfad | awk -F / '{print $6}' # $6 ist relativ zur Pfadlaenge

# Protokollbezeichner entfernen

url="ftp://ftp.debian.org"
echo ${url##*/}
-> ftp.debian.org

### Zeichen abschneiden

foo='abcdefg'

echo ${foo:(-2)}       # bash
-> fg

echo ${foo:5}          # bash
-> fg

echo ${foo[6,7]}       #zsh
-> fg

echo ${foo[-2,-1]}     #zsh
-> fg


###
# sed
# die ersten x zeichen einer zeile entfernen

sed -e '/match/s/^.\{x\}\(.*\)/\1/' file.txt
sed -e 's/.\{12\}/ /' file.txt

### text am anfang einer datei einfÃ¼gen
sed '1itext'  file.txt

### text vor suchmuster einfÃ¼gen
sed '/pattern/i\text' file.txt

### kommentarzeilen entfernen
sed 's/^#.*//g' file.txt

### doppelbuchstaben ausgeben
sed -n '/\([a-z]\)\1/p' file.txt

### IP aus Textdatei filtern
sed -n '/\([0-9]\{1,3\}\.\)\{3,\}[0-9]\{1,3\}/p'
# html-tags rausfiltern
sed -n '/\([0-9]\{1,3\}\.\)\{3,\}/p' | sed 's/<[^>]*>//g'

### leerzeichen aus datei entfernen
sed 's/\ //g' file

### leerzeichen aus dateinamen entfernen
rename 's/\ //g' *


# mit perl
perl -ne 'while (/([0-9]+\.){3}[0-9]+/g) {print "$&\n"};' a.txt

##
# zsh

# reverse a word

echo "${(j::)${(@Oa)${(s::):-hello}}}"

# Mal schnell alle Pics von $PWD nach $PWD/Pics/ verschieben

mv *(#i).(jp[e]g|gif|png) $PWD/Pics

# Die ganzen Backups der Textdateien (foobar.txt~) loeschen

rm **/*~

###
# Dateien verschieben, umbenennen

# mv /var/www/htdocs/homepage/zsh/index.hmlt /var/www/htdocs/homepage/zsh/index.html

mv /var/www/htdocs/homepage/zsh/index.{hmlt,html}

### mehrere Dateien verschieben
for a in  ; do mv $a /new/path/ ; done

###  alle dateien mit endung ext1 in endung ext2 zu aendern.
for f in *.ext1 ; do mv "$f" ${f%.ext1}.ext2 ; done

### Endung .sh entfernen
for a in *.sh; do mv $a ${a%.*}; done


# Die MP3s mit lame(1) zu *.wav konvertieren

zmv -n -p lame -o --decode '(*).mp3' '${1:r}.wav'     # zsh

### Anzahl von files
FILES=(*.txt)            # bash
echo ${#FILES[@]}

### Alle user anzeigen
cat /etc/passwd |cut -f1 -d:  # bash

# mit /home Verzeichnissen
awk -F : '{print NR,$1,$6}' /etc/passwd

### Verzeichnis sÃ¤ubern

for i in $(find /path -name \*foo); do rm -f $i; done
find /path -name \*foo -exec rm -f {} \;


### Mit test (if) mehrere Bedingungen zusammenfassen ###

if [ $var = "a" -o $var = "b" ]; then
 Befehl
 fi

## Oder: ###

 if [[ $var = "a" || $var = "b" ]]; then
  Befehl
fi

## Besser: ###
 if [ -n "$var"] && [ -e "$var"]; then
    echo "\$var is not null and a file named $var exists!"
fi

### Noch mehr Bedingungen ###

 if  [ "true" ] || { [ -e /does/not/exist ]  && [ -e /does/not/exist ] ;}; then
  echo true
   else echo false
fi

#

if [ 1 -eq 0 -o ( 0 -ne 1 -a 1 -eq 1 ) ]; then
 ...
fi

#

if [ 1 -eq 0 ] || [ 0 -ne 1 ] && [ 1 -eq 1 ]; then
...
fi

#

if [ 1 -eq 0 ] || { [ 0 -eq 1 ] && [ 1 -eq 1 ] ;}; then
...
fi

# Are you root?

[ $UID = 0 ] && echo "true" || echo "false"

###
# Verzeichnisse

### Verzeichnisgroesse addieren
echo $(($(du -s $dir1 | awk '{print $1}') + $(du -s $dir2 | awk '{print $1}')))

### Verzeichnis leer?
 if [ $(ls -l leer/ | wc -l) -gt "1" ]; then echo "nicht leer"; else echo "leer"; fi

### Leerzeichen in einer Variablen durch "_" ersetzen

a="a b c d"
b=${a// /_}

echo $b
-> a_b_c_d

### manpages greppen

man < befehl >|grep -A50 '^[[:space:]]*< pattern >[[:space:]]*\[' > pattern.txt
man < befehl > | less -p < pattern >

##
# Mehrere Bilder konvertieren
#
# Mit gleicher Endung
for a in *.png; do convert $a -resize 640x480 ${a%.png}-2.png; done

# Mit anderer Endung
for a in *.png; do convert $a -resize 640x480 ${a%.png}.jpg; done

# Text mit singlequotes
echo 'text with '\''singlequotes'\''' > file

###
# Perl
#
### Zu einer IP-Adresse den Hostnamen ermitteln
perl -e 'print gethostbyaddr((pack('C4',(split /\./,$ARGV[0]))),2)."\n"' IP

### Zu einem Hostnamen die IP-Adresse ermitteln
perl -e 'print join(".",unpack('C4',scalar(gethostbyname($ARGV[0]))))."\n"' host.domain

### Datei splitten
perl -a -F: -n -e 'print"@F[0]n"' < /etc/passwd 

### Suchen und ersetzen
perl -pi -e "s/OldText/NewText/g" file.txt

### Mehrere Dateien gleichzeitig nach best. Muster umbenennen
perl -e "for my $n (<*.jpg>){my $a=$n; $a=~s!^(.).*?(...a?\.jpg$)!$1-$2!; rename $n,$a}"

### zeilen einer datei mit zeilennummern ausgeben
perl -e '$i=1;while(<>){print "$i: $_";$i++}'

### klassische SH forkbomb
#:() { :|:& };:
