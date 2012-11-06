#!/bin/sh

log()
{
	echo "INSTALL.SH:" $@ >> /var/log/syslog
}

log "Beginning post installation script"

INSTSERVER="http://10.0.0.1"

log "Adding SSH Keys"

mkdir /target/root/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxaadBnI+O3nr04KC0cbegPip3bAmGYbdJ7qi3XFZecqiGbLFH9Pwj7IzZmsFnpmjwOz5vN2VbXLLLj8I6RdS6rlimZhBl4ljsc6fkXOJPwq9RwypMlJKiMj4l55qN1F8JDIOl0gobK1Ju4NOb5sXBWwwei94tD5sDx9LG+u9VspdPNPW5l1o6IXl1hTSp8ii45hFbSkNJnPJlj1YKEFXbbTtWNUozwpIxle1CpeSz1n1J3AUOLa0pE2ShULysbmmq9gsKIqlBrEa/FmPdf5SHoxBe0NocQ90iHR1shAfeE1hBD0/2iv/KxGoLVJ+yigeo/h38hFeeNno1oAh59tDpw== andreas@siduxbox" > /target/root/.ssh/authorized_hosts

log "DONE"

log "fetching config.tar.gz"
wget $INSTSERVER/debian/config.tar.gz -qO /target/root/config.tar.gz 2 >> /var/log/syslog
log "DONE"

log "unpacking config.tar.gz into /target/root ..."
cd /target/root
tar -xzf /target/root/config.tar.gz
log "DONE"

log "Applying config to target..."
cp -r /target/root/config/* /target/
log "DONE"

log "Updating grub config"
chroot /target /usr/sbin/update-grub2 >> /var/log/syslog
log "DONE"

log "Updating Debian package cache"
chroot /target /usr/bin/apt-get update >> /var/log/syslog
log "DONE"



log "copy syslog to target"
cp /var/log/syslog /target/root/install.log
log "DONE"


log "Finished config exiting" 
exit 0
