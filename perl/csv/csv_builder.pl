#!/usr/bin/perl

=head1 NAME

csv_builder - make/interact with csv tables

=head1 SYNOPSIS

csv_builder -p ./csv -q "create table mytable(id INTEGER, name CHAR (10))"

csv_builder -p ./csv -q "insert into mytable (id, name) values(1, 'frank')"

csv_builder -p ./csv -q "select * from mytable;"

=head1 DESCRIPTION

Runs queries against a local database of csv files in a directory.
Each table is one csv file.

=cut

use 5.010_000;

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use DBI;

our $VERSION = '0.1';

my ($path,   # path to the csv data
    $query,  # query to be sent
    $dbh,    # db handler
    $sth     # statement handler
   );

my $result = GetOptions (
  "p|path=s"         => \$path,
  "q|query=s"        => \$query,
  "h|help"           => sub { pod2usage(-exitval   => 0,
					-verbose   => 99,
					-noperldoc => 1) });


die "ERROR: No such directory $path" if ( ! -d $path );

$dbh = DBI->connect ("dbi:CSV:",undef, undef,
		    { f_dir        => $path,
		      f_ext        => ".csv/r",
		      f_encoding   => "utf8",
		      csv_eol      => "\r\n",
		      csv_sep_char => ",",
		      RaiseError   => 1,
		      PrintError   => 1,
		     }) or die "$DBI::errstr";

$dbh->do ($query) or die $dbh->errstr();
$dbh->disconnect();
