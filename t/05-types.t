#!/usr/bin/perl  -sw 
# Test script for Zone functionalty
# $Id: 05-types.t,v 1.1 2004/04/27 14:11:41 olaf Exp $
# 
# Called in a fashion simmilar to:
# /usr/bin/perl -Iblib/arch -Iblib/lib -I/usr/lib/perl5/5.6.1/i386-freebsd \
# -I/usr/lib/perl5/5.6.1 -e 'use Test::Harness qw(&runtests $verbose); \
# $verbose=0; runtests @ARGV;' t/05-types.t

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.
#use Test::More tests=>24;
use Test::More;
use strict;






# Each of these RR Types are known to have dname in their RDATA.
#      NS, CNAME, SOA, MB, PTR, MG, MR, PTR, MINFO, MX, RP, AFSDB, RT,
#      SIG, NXT, SRV, KX, DNAME, NSEC,  and RRSIG

# test.types.db contains a a zone with each of these RRtypes.
# They are listed in exactly the same order as below.
# All have "example.com as owner name and a TTL of 60".
#
#  This array contains exactly the same RRs as in test.types.db in
# the same order.
#

my @rrs = (
    {	#[1]
	type         => 'SOA',
	mname        => 'soa-mname.example.com',
	rname        => 'soa-rname.example.com',
	serial       => 12345,
	refresh      => 7200,
	retry        => 3600,
	expire       => 2592000,
	minimum      => 86400,
    },
    
    {	#[2]
	type         => 'AFSDB',
	subtype      => 1,
	hostname     => 'afsdb-hostname.example.com',
    }, 
    {	#[3]
	type         => 'CNAME',
	cname        => 'cname-cname.example.com',
    }, 
    {   #[4]
	type         => 'DNAME',
	dname        => 'dname.example.com',
    },
    {	#[5]
	type         => 'MB',
	madname      => 'mb-madname.example.com',
    }, 
    {	#[6]
	type         => 'MG',
	mgmname      => 'mg-mgmname.example.com',
    }, 
    {	#[7]
	type         => 'MINFO',
	rmailbx      => 'minfo-rmailbx.example.com',
	emailbx      => 'minfo-emailbx.example.com',
    }, 
    {	#[8]
	type         => 'MR',
	newname      => 'mr-newname.example.com',
    }, 
    {	#[9]
	type         => 'MX',
	preference   => 10,
	exchange     => 'mx-exchange.example.com',
    },
    {	#[10]
	type         => 'NAPTR',
	order        => 100,
	preference   => 10,
	flags        => 'naptr-flags',
	service      => 'naptr-service',
	regexp       => 'naptr-regexp',
	replacement  => 'naptr-replacement.example.com',
    },
    {	#[11]
	type         => 'NS',
	nsdname      => 'ns-nsdname.example.com',
    },
    {	#[12]
	type         => 'PTR',
	ptrdname     => 'ptr-ptrdname.example.com',
    },
    {	#[13] 
	type         => 'PX',
	preference   => 10,
	map822       => 'px-map822.example.com',
	mapx400      => 'px-mapx400.example.com',
    },
    {	#[14]
	type         => 'RP',
	mbox		 => 'rp-mbox.example.com',
	txtdname     => 'rp-txtdname.example.com',
    },
    {	#[15]
	type         => 'RT',
	preference   => 10,
	intermediate => 'rt-intermediate.example.com',
    },
    {	#[16]
	type         => 'SRV',
	priority     => 1,
	weight       => 2,
	port         => 3,
	target       => 'srv-target.example.com',
    },
    
    {
	type         => 'SIG',
	typecovered  => "AAAA",
	algorithm    => 5,
	labels       => 3,
	orgttl       => 3600,
	sigexpiration =>  20040101000010,
	siginceptation => 20030101123000,
	keytag        => 12345,
	signame       => "bla.example.com",
	sig           => "abcdefghijklmn=="
    },

    {
	type         => 'RRSIG',
	typecovered  => "AAAA",
	algorithm    => 5,
	labels       => 3,
	orgttl       => 3600,
	sigexpiration =>  20040101000010,
	siginceptation => 20030101123000,
	keytag        => 12345,
	signame       => "bla.example.com",
	sig           => "abcdefghijklmn=="
	
    },
    {   type  => 'NSEC',
	nxtdname => "aaaa.example.com",  # Note that in the zonefile we write
	                                 # AAAA but the NSEC read_string will
	                                 # cast to lowercase.
	typelist =>  "A AAAA LOC",
    },

	   
    {   type  => 'NXT',
	nxtdname => "a.example.com",  # Note that in the zonefile we write
	                                 # AAAA but the NSEC read_string will
	                                 # cast to lowercase.
	typelist =>  "A AAAA LOC",
    }
# KX
    
);

plan tests => 2+(scalar @rrs);

use Net::DNS::Zone::Parser;
use Net::DNS::SEC;


use Shell qw (which);
my $named_checkzone = which("named-checkzone");
$named_checkzone =~ s/\s+$//;
my $nocheckzone=0;

if ( !( -x $named_checkzone )){
    diag "Some additional tests are performed if named-checkzone is in your path.";

$nocheckzone=1;
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


$parser->read("t/test.types.db",{ ORIGIN=> "example.com",
				     CREATE_RR => 1});


my $array=$parser->get_array();
is (  scalar @{$array}, 20 , "all RRs read from zonefile");





foreach my $data (@rrs) {
    my $parsed_rr=shift @$array;
    my $rr=Net::DNS::RR->new(
	name => "example.com",
	ttl  => 60,
	%{$data},	     
    );			
#    print $rr->string;
    is ($parsed_rr->string,			
    $rr->string, "dname expansion in ". $rr->type );
    
}					
	
			
