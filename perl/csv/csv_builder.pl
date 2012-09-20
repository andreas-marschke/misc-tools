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

=head2 -n --notbl 

Be terse and don't print an ascii table for the results of SELECTs/UPDATEs.

=head2 -p --path [PATH]

The path to a directory containing multiple *.csv files. This directory is then handled
like a database. The *.csv files are the tables.

=head2 -q --query [STRING] 

The SQL Query you would like to execute.

=head2 -d --delim [CHAR]

CHAR is the cell delimiter of your csv files.

=head2 -h --help
Show this help

=cut

use 5.010_000;

use strict;
use warnings;
use utf8;

use Text::TabularDisplay;
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;
use File::Slurp;
use DBI;

our $VERSION = '0.1';
my ($path,   # path to the csv data
    $query,  # query to be sent
    $dbh,    # db handler
    $sth,    # statement handler
    $notbl,  # ifdef no tabular display
    $delim,  # delimiter on output works only with notbl
    $file
   );

my $result = GetOptions (
  "f|file=s"         => \$file,
  "n|notbl"          => \$notbl,
  "p|path=s"         => \$path,
  "q|query=s"        => \$query,
  "d|delim=s"        => \$delim,
  "h|help"           => sub { pod2usage(-exitval   => 0,
					-verbose   => 99,
					-noperldoc => 1) });

$query = read_file($file) if ( defined $file && -f $file );
chomp($query)
;
die "ERROR: No such directory $path" if ( ! -d $path );

$delim = "," unless defined $delim;
$dbh = DBI->connect ("dbi:CSV:",undef, undef,
		    { f_dir        => $path,
		      f_ext        => ".csv/r",
		      f_encoding   => "utf8",
		      csv_eol      => "\r\n",
		      csv_sep_char => $delim,
		      RaiseError   => 1,
		      PrintError   => 1,
		     }) or die "$DBI::errstr";

$sth = $dbh->prepare($query);
$sth->execute();
# if its a select statement
if ($sth->{NUM_OF_FIELDS} gt 0 ) {
  if (defined $notbl) {
   while (my @row = $sth->fetchrow) {
     my $text = join($delim, @row);
     utf8::encode($text);
     print $text."\n";
   } 
 } else {
   my $t = Text::TabularDisplay->new();
   my $row = $sth->fetchrow_hashref;
   $t->columns(reverse(keys $row));
   $t->add(reverse(values $row));
   while (my @row = $sth->fetchrow) {
     $t->add(@row);
   }
   my $rendered_text = $t->render();
   utf8::encode($rendered_text);
   print  $rendered_text;
   print "\n";    
 }

}
$sth->finish ();
$dbh->disconnect();
