#!/usr/bin/perl  -sw 
# Test script for Zone functionalty
# $Id: 02-parser.t,v 1.5 2004/06/23 10:13:11 olaf Exp $
# 
# Called in a fashion simmilar to:
# /usr/bin/perl -Iblib/arch -Iblib/lib -I/usr/lib/perl5/5.6.1/i386-freebsd \
# -I/usr/lib/perl5/5.6.1 -e 'use Test::Harness qw(&runtests $verbose); \
# $verbose=0; runtests @ARGV;' t/01-zonetest.t

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

use Test::More tests=>8;
use strict;






#use Data::Dumper;

BEGIN {use_ok('Net::DNS::Zone::Parser');
       use_ok('Net::DNS::SEC');
      }                                 # test 2


use Shell qw (which);
my $named_checkzone = which("named-checkzone");
$named_checkzone =~ s/\s+$//;




my $nocheckzone=0;


if ( !( -x $named_checkzone )){
    diag "Some additional tests are performed if named-checkzone is in your path.";
    $nocheckzone=1;
}

if (! $nocheckzone ){
    my $named_checkzone_version=`$named_checkzone -v`;
    my($branch,$major,$minor,$other)= $named_checkzone_version=~/(\d+)\.(\d+)\.(\d+)(.*)/;
    if ($branch<9 || ($branch==9 && $major<3) ){
	diag ("This version of named-checkonf does not know about DNSSEC, some tests will be skipped");
	$nocheckzone=1;
    }
}


my $parser;
my $fh = new IO::File "> t/TMP_ZONE";
if (defined $fh){
# Create a new object
    $parser = Net::DNS::Zone::Parser->new($fh);
}else{
    $parser = Net::DNS::Zone::Parser->new();
}
    

ok( defined($parser), "Parser object creation");                        # test 2


$parser->read("t/test.db",{ ORIGIN=> "foo.test",
				     CREATE_RR => 1});


my $array=$parser->get_array();
is (  scalar @{$array}, 12 , "12 RRs read from zonefile");


#
#  Some minor content checks on the zone content.
# 

my $sigrr=Net::DNS::RR->new('z.x.c.d.foo.test.       1500    IN      RRSIG   AAAA  1  3  172800  20011028163938 (
                     20010928163938 39250  bla.foo.test.
                     AeYY2IgScHDWq6zRfyzCdimqA3de9Sb/Ivw7PoMcvJr7f
                     7gtqF9IWpTdH7KNd1tPAHbiIAfjmsXIgOOAL0TChQ== )');

foreach my $rr (@{$array}){

    is ($rr->string, 'z.x.c.d.foo.test.	1500	IN	TXT	"Multiple line f.nny" "<xml> typed </xml" "text resource record"', "multiline TXT RR parsed correctly")
      if ($rr->name eq "z.x.c.d.foo.test" && $rr->type eq "TXT");

    
    is( $rr->string,'foo.test.	3600	IN	SOA	ns1.foo.test. root.localhost. (
					2002021201	; Serial
					450	; Refresh
					600	; Retry
					345600	; Expire
					300 )	; Minimum TTL'
      ,"SOA RR parsed correctly")
  if ($rr->name eq "foo.test" && $rr->type eq "SOA");

    is ($rr->string, $sigrr->string,
    "dname in RRSIG completed.") if ($rr->name eq "z.x.c.d.foo.test" && $rr->type eq "RRSIG");


}




if (! $nocheckzone ){

    open(VERSION,"$named_checkzone -v|");
    $_=<VERSION>;
    chop;
    /^(\d+)\.(\d+)\.(\d+)/;
    my ($release,$major,$minor)=($1,$2,$3);
    $nocheckzone=$_ unless ($release >= 9 && $major >= 3 && $minor>= 0); 	

}


SKIP: {
  skip "No suitable named-checkzone ($nocheckzone) found on the system", 
    1 if 
      $nocheckzone || ! defined ($fh);
  
  system($named_checkzone ,"foo.test","t/TMP_ZONE");
    is ($?,0,"named_checkzone checked the zone");
};  #  end SKIP





