#!/usr/bin/perl


use strict;
use warnings;
use Net::Bluetooth;
use Getopt::Long;

my $file;
my $help;
my $name;
my $addr;
my $search;
my $server;
my $result= GetOptions ("help"   => \$help ,
			"file=s" => \$file ,
			"name=s" => \$name ,
			"addr=s" => \$addr ,
			"search" => \$search ,
			"server" => \$server);

if($help)
{
    print <<"EOF";
Sendfile.pl - Send files quickly via Bluetooth
written by Andreas Marschke
Options: 
--help          : show help and exit.
--file FILE     : send FILE.
--addr ADDR     : send file to ADDR
--search        : look for Bluetoothdevices
--name NAME     : send File to NAME
--server        : make it a server
EOF
exit 0;

}

if($search)
{
    #### list all remote devices in the area
    my $device_ref = get_remote_devices();
    foreach my $addr_ (keys %$device_ref) {
	print "Address: $addr_ Name: $device_ref->{$addr_}\n";
    }
    exit 0;
}

if($addr || $name && $file)
{
    my $device_ref = get_remote_devices();
    foreach my $addr_ (keys %$device_ref) {
	$addr = $addr_;
	
	if("$device_ref->{$addr_}" eq "$name" ) 
	{	    
            #### Create a RFCOMM client 
	    my $obj = Net::Bluetooth->newsocket("RFCOMM");
	    die "socket error $!\n" unless(defined($obj)); 
	    
	    if($obj->connect($addr, 1) != 0) {
		die "connect error: $!\n";
	    }

	    my @sdp_array = sdp_search($addr, "0", "");
	    foreach my $sdp (@sdp_array)
	    {
		if($sdp->{'SERVICE_NAME'} =~ m/"OBEX File Transfer"/){
		    obj->bind($sdp->{'RFCOMM'});
		    obj->connect($addr,$sdp->{'RFCOMM'});
		    *SOCKET = $obj->perlfh();
		    open(FILE,'<',$file);
		    while(<SOCKET>){
			print  $_;
		    }
		    close(FILE);
		    close(SOCKET);
		}
	    }
	    
	}
    }
}

if($addr || $name && $server)
{
    print "starting server...\n";
    
    my $device_ref = get_remote_devices();
    if( $addr)
    {
	print "Address:".$addr." finding name...\n";
	foreach my $addr_ (keys %$device_ref) {
	    if($addr_=~ m/$addr/i)
	    {
		$name = "%$device_ref->{$addr_}";
	    }
	}
	print "Name is:".$name."\n";
    } 
    else 
    {
	print "Name:".$name." finding address...\n";
	foreach my $addr_ (keys %$device_ref) 
	{
	    if($name eq %$device_ref->{$addr_} )
	    {
		$addr = $addr_;
	    }
	}
	print "Address found: ".$addr."\n";
    }
    my @sdp_array = sdp_search($addr, "0", "");
    foreach my $sdp (@sdp_array) {
	
	if($sdp->{'SERVICE_NAME'} =~ m/HID/i){
	    print "connecting to port:".$sdp->{'RFCOMM'}." for HID service\n";
	    my $obj = Net::Bluetooth->newsocket("RFCOMM");
	    $obj->bind($sdp->{'RFCOMM'}); # bind to port 
	    # obj->connect($addr,$sdp->{'RFCOMM'}); 
	    $sdp->newservice($obj,"0",$sdp->{'SERVICE_NAME'},$sdp->{'SERVICE_DESC'});
	    print "now listening.\n";
	    $obj->listen(50);
	    *SOCKET = $obj->perlfh();
	   
	    while(<SOCKET>){
		print  $_;
	    }
	    close(SOCKET);
	    $sdp->stop_service();
	    print "stopped listening\n";
	    exit 0;
	}
    }
}
 
