#!/usr/bin/perl

=head1 NAME

nrpe2service - turn NSC.ini files into nagios checks

=head1 SYNOPSIS

 nrpe2service --nsc NSC.ini --template service.tpl 

=head1 DESCRIPTION

Create a batch of servicechecks for nagios from an NSClient ini file.
It needs a Template for the host and a template for the services.

A service template MAY look like this:

 define service {
     use                 generic-service
     host_name           $HOST$
     service_description $DESC$
     check_command       check_nrpe_1arg!$CHECK$
     contact_groups          +oncall
 }

The values of $HOST$,$DESC$ and $CHECK$ will be replaced.
An appropriate host-template may look like this:

 define host {
         use             windows-server
         host_name       $HOST$
         alias           $HOST$.example.org
         address         192.168.0.33
         hostgroups      windows-servers,nsclients
         parents         firewall
 }
$HOST$ will be replaced by whatever you set with the --host option.

=head1 OPTIONS

These are the options you can use.

=head2 -h --help

Shows this help
              
=head2 -n --nrpe NSC

The NSCliet file from which checks are created 

=head2 -t --template TEMPLATE

The service template for the checks

=head2 -H --hosttemplate HOSTTEMPLATE

The prepended HOSTTEMPLATE file

=head2 --host HOST

The HOST which replaces the $HOST$ variable when creating the script

=head2 -o --output OUTPUT

Writes the created service-checks into the OUTPUT-file. You can specify 
STDOUT if you want to  print to the terminal. If not specified prints to STDOUT

=cut



our $VERSION = '0.001';

use 5.010_000;

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use IO::File;
use Pod::Usage;
use File::Slurp;
use Config::INI::Reader;

my ($output,
    $host,
    $host_tpl,
    $nsc,
    $template,);

my $result = GetOptions (
  "h|help"           => sub { pod2usage( -exitval   => 0,
		     			 -verbose   => 99,
					 -noperldoc => 1 ) },
  "n|nrpe=s"          => \$nsc,
  "t|template=s"     => \$template,
  "H|hosttemplate=s" => \$host_tpl,
  "host=s"           => \$host,
  "o|output=s"       => \$output );

$host = "localhost" unless defined $host;

my $content_template = read_file ( $template );
my $content_host_template = read_file ( $host_tpl );
my @nsc_content = read_file($nsc);

my @aliases = grep m/^command\[[\w_]*\]=/,@nsc_content;
my @new_aliases;
foreach (@aliases) {
  if (m/^command\[([\w\_]*)\]=/) {
	push @new_aliases,$1;
  }
}

foreach my $check ( @new_aliases) {
  my $template = $content_template;
  $template =~ s/\$CHECK\$/${check}/;
  $template =~ s/\$DESC\$/${check}/;
  $template =~ s/\$HOST\$/${host}/;
  $content_host_template .= $template."\n";
}

if ( !defined $output) {
  print $content_host_template;
} else {
  my $file = $output; 
  open( FILE, '>', $output );
  print FILE $content_host_template;
  close (FILE);
}

