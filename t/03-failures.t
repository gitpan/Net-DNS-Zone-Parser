#!/usr/bin/perl  -sw 
# Test script for Zone functionalty
# $Id: 03-failures.t,v 1.1 2004/03/09 13:58:34 olaf Exp $
# 
# Called in a fashion simmilar to:
# /usr/bin/perl -Iblib/arch -Iblib/lib -I/usr/lib/perl5/5.6.1/i386-freebsd \
# -I/usr/lib/perl5/5.6.1 -e 'use Test::Harness qw(&runtests $verbose); \
# $verbose=0; runtests @ARGV;' t/01-zonetest.t

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

use Test::More tests=>5;
use strict;


BEGIN {use_ok('Net::DNS::Zone::Parser');
      }                                 # test 1


# Create a new object
my $parser = Net::DNS::Zone::Parser->new();
ok( defined($parser), "Parser object creation");                        # test 2

like( $parser->read("t/test.db.recurse1",{ ORIGIN=> "foo.test"}),
      "/^READ FAILURE: Nested INCLUDE more than 20 levels deep/",
      "Nested INCLUDE error returned");


like  ($parser->read("t/test.db.brokenRR",{ ORIGIN=> "foo.test"}),
       "/^READ FAILURE: \"foo.test. 3600 IN NAASS bla.foo\"/"
       ,"Regular Expression of RR fails");


like ($parser->read("t/test.db.brokenbrackets",{ ORIGIN=> "foo.test"}),
     '/^READ FAILURE: Multiple enclosing opening brackets/'
      ,"Multiple opening brackets error");

