#!/usr/bin/perl
# This will download all available pdfs from the ALP Books Website
# http://www.advancedlinuxprogramming.com/alp-folder
use warnings;              # so we know when something small went wrong
use strict;                # propper perl code needs that
use HTML::TableExtract;    # the core theme of this example.
use LWP::Simple;

my $content = get("http://www.advancedlinuxprogramming.com/alp-folder");
die "Couldn't get it!" unless defined $content;

my $te = HTML::TableExtract->new( keep_html => 1 );
$te->parse($content);
foreach my $ts ( $te->tables ) {
    foreach my $row ( $ts->rows ) {
        my $index = 1;
        @$row[$index] .= " ";
        @$row[$index] =~ s/<[[:alnum:]\ ]*=\"//g;
        @$row[$index] =~ s/\"[[:alnum:]\ <>\/]*//g;

        if ( @$row[$index] =~ m/[^\ ]\+*/ )
        {    # we want only the ones with content
            my $url = "http://www.advancedlinuxprogramming.com/alp-folder/"
              . @$row[$index];
            print "http://www.advancedlinuxprogramming.com/alp-folder/"
              . @$row[$index] . "\n";
            print "Downloading ...\n";
            getstore( $url, @$row[$index] );
        }
    }
}
