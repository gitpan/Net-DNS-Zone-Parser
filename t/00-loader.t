#!/usr/bin/perl  -sw 
# Test script for loading parser and zonemodules
# $Id: 00-loader.t,v 1.1 2004/03/09 11:44:29 olaf Exp $
# 
# Called in a fashion simmilar to:
# /usr/bin/perl -Iblib/arch -Iblib/lib -I/usr/lib/perl5/5.6.1/i386-freebsd \
# -I/usr/lib/perl5/5.6.1 -e 'use Test::Harness qw(&runtests $verbose); \
# $verbose=0; runtests @ARGV;' t/<foo>

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.


use Test::More tests=>2;
use strict;

#use Data::Dumper;
BEGIN {use_ok('Net::DNS::Zone::Parser', qw(processGENERATEarg));


      }                                 # test 1



require_ok('Net::DNS::Zone::Parser');


