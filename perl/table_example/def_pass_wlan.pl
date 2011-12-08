#!/usr/bin/perl
use warnings;              # so we know when something small went wrong
use strict;                # propper perl code needs that
use Getopt::Long;          # for options
use HTML::TableExtract;    # the core theme of this example.

my $get_h;
my $get_f = "";
my $result = GetOptions( "f|file=s" => \$get_f, "h|help" => \$get_h );

sub help() {
    print <<"EOF";
TableOfDefaultPasswords written by Andreas Marschke <xxtjaxx[AT]gmail.com>
Synopsis:  dentsh [OPTIONS]
OPTIONS: -h,--help     show help
         -f,--file     file to read from
EOF
    exit 0;
}

if ($get_h) {
    &help;
}
unless ($get_f) {
    &help;
}
my $content = "";
print $get_f. "\n";

#crack open the file and get whats in there.
open( FILE, "<", $get_f ); # we assume only one file at a time will be requested
while (<FILE>) { $content .= $_; }

## Here is the real magic
my $te = HTML::TableExtract->new();
$te->parse($content);

#for each table in the parsed content find the row 6 and print its content
foreach my $ts ( $te->tables ) {
    foreach my $row ( $ts->rows ) {
        my $index = 5;
        @$row[$index] .= " ";
        if ( @$row[$index] =~ m/[^\ ]\+*/ )
        {    # we want only the ones with content
            print "\t" . @$row[$index] . "\n";
        }
    }
}

