#!/usr/bin/perl

=head1 NAME

csv_builder - make/interact with csv tables

=head1 SYNOPSIS

csv_builder -p ./csv -q "create table mytable(id INTEGER, name CHAR (10))"

csv_builder -p ./csv -q "insert into mytable (id, name) values(1, 'frank')"

csv_builder -p ./csv -q "select * from mytable;" -d single

=head1 DESCRIPTION

Runs queries against a local database of csv files in a directory.
Each table is one csv file.

=cut

use 5.010_000;

use strict;
use warnings;
use utf8;

use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use DBI;

our $VERSION = '0.1';
my ($path,   # path to the csv data
    $query,  # query to be sent
    $dbh,    # db handler
    $sth    # statement handler
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

$sth = $dbh->prepare($query);
$sth->execute();
# if its a select statement
if ($sth->{NUM_OF_FIELDS} gt 0 ) {
  use Text::TabularDisplay;
  my $t = Text::TabularDisplay->new();
  my $row = $sth->fetchrow_hashref;
  $t->columns(keys $row);
  $t->add(values $row);
  while (my @row = $sth->fetchrow) {
    $t->add(@row);
  }
  my $rendered_text = $t->render();
  utf8::encode($rendered_text);
  print  $rendered_text;
  print "\n";
}
$sth->finish ();
$dbh->disconnect();
