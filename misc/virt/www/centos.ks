#
# Minimal RHEL5 Installation

install
# Mirror URL
url --url http://mirror.netcologne.de/centos/6/os/x86_64/
lang en_US.UTF-8
keyboard de-latin1-nodeadkeys
network --device eth0 --bootproto dhcp
# Your root password
rootpw test1234 
firewall --enabled --ssh
firstboot --disable
authconfig --enableshadow --enablemd5
selinux --enforcing
# Timezone, change as needed
timezone --utc Europe/Berlin
bootloader --location=mbr --append="console=tty0 console=ttyS0,115200n8r"
# Append the following line if you need serial console support
#--append="console=tty0 console=ttyS0,115200n8r"
# or for Xen:
#--append="console=tty0 console=xvc0"
key --skip
logging --host=You syslog server
skipx
# uncomment if you only need a text mode installation
text
# interactive
reboot
services --disabled ip6tables
services --enabled ntpd
clearpart --initlabel --all
autopart

# Packages selection.
%packages --nobase
kernel
yum
openssh-server
openssh-clients
dhclient
audit
man
logrotate
tmpwatch
vixie-cron
crontabs
system-config-network-tui
system-config-firewall-tui
ntp
wget
# Remove some stuff we do not need.
-gnu-efi
-Deployment_Guide-en-US
-redhat-release-notes
-cryptsetup-luks
-hal
-pm-utils
-dbus
-dbus-glib
-kudzu
-ecryptfs-utils

# Run a post script to clean up a bit
%post
chvt 3
(
echo "Disabling IPv6"
sed -i -e 's/\(NETWORKING_IPV6=\).*/\1no/' /etc/sysconfig/network

cat << EOF >> /etc/modprobe.conf
# disable IPv6
alias net-pf-10 off
EOF

echo "Disabling Zeroconf"
grep -q '^NOZEROCONF=yes' /etc/sysconfig/network || sed -i -e '/^NETWORKING=yes/a NOZEROCONF=yes' /etc/sysconfig/network

# Running on x86_64? Remove i386 rpms
if [ "$(uname -m)" == "x86_64" ]; then
	echo "We're on x86_64, removing unwanted i386 libraries"
	rpm -qa --queryformat='%{n}-%{v}-%{r}.%{arch}\n' | grep '\.i[3456]86$' | xargs rpm -ev
	echo "done"
fi

# Adding ssh key
# You could add your ssh key here
echo "Adding ssh key"
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo -e 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxaadBnI+O3nr04KC0cbegPip3bAmGYbdJ7qi3XFZecqiGbLFH9Pwj7IzZmsFnpmjwOz5vN2VbXLLLj8I6RdS6rlimZhBl4ljsc6fkXOJPwq9RwypMlJKiMj4l55qN1F8JDIOl0gobK1Ju4NOb5sXBWwwei94tD5sDx9LG+u9VspdPNPW5l1o6IXl1hTSp8ii45hFbSkNJnPJlj1YKEFXbbTtWNUozwpIxle1CpeSz1n1J3AUOLa0pE2ShULysbmmq9gsKIqlBrEa/FmPdf5SHoxBe0NocQ90iHR1shAfeE1hBD0/2iv/KxGoLVJ+yigeo/h38hFeeNno1oAh59tDpw== andreas@siduxbox' > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "Adding vimrc"
echo -e "syntax on\nhighlight Comment ctermfg=Cyan\nset ts=4" > /root/.vimrc
echo -e '#higher conntrack\noptions ip_conntrack hashsize=32768\n' >> /etc/modprobe.conf

rpm -U http://ftp-stud.hs-esslingen.de/pub/epel/6/i386/epel-release-6-7.noarch.rpm
yum -y install yum-priorities centos-release-cr

wget -q -O /tmp/config.tar http://192.168.254.1/config/config6.tar

yum -y install exim
yum -y remove postfix
chkconfig exim on
tar -C /etc -xf /tmp/config.tar

yum -y update
chkconfig ntp on

) 2>&1 | tee /root/ks-post.log
chvt 1
