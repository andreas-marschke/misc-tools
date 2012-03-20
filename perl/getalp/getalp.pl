#!/usr/bin/perl
# This will download all available pdfs from the ALP Books Website
# http://www.advancedlinuxprogramming.com/alp-folder
use warnings;              # so we know when something small went wrong
use strict;                # propper perl code needs that
use HTML::TableExtract;    # the core theme of this example.
use LWP::Simple;
use threads ('yield',
	     'exit' => 'threads_only',
	     'stringify');

sub download_pdf{
  my $filename = shift;
  # we want only the ones with content
  my $url = "http://www.advancedlinuxprogramming.com/alp-folder/" . $filename;
  getstore( $url, $filename );
}

my @threads;
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
    if ( @$row[$index] =~ m/[^\ ]\+*/ ) {
      push @threads,threads->create(\&download_pdf, @$row[$index]);
      
    }
  }
}

for my $thread (@threads) {
  $thread->join();
  $thread->yield();
}
