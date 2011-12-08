#!/usr/bin/perl

=head1 NAME

  twig_test.pl - a small-ish test script to try XML::Twig

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use 5.010_000;

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use IO::File;
use Pod::Usage;
use XML::Twig;

our $VERSION = '0.1';

my $result = GetOptions (
  "h|help"           => sub { pod2usage(-exitval   => 0,
					-verbose   => 99,
					-noperldoc => 1) });

