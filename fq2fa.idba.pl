#!/usr/bin/perl
use strict;
use Data::Dumper;
use PerlIO::gzip;
my ($fq1,$fq2,$out,$type) = @ARGV;
die "perl $0 <r1.fq.gz> <r2.fq.gz> <out.fa.gz> \n" if(@ARGV!=3);
open(IN1,"<:gzip","$fq1"); open(IN2,"<:gzip","$fq2");
if($out=~/\.gz/){open (OUT,">:gzip","$out");}else{open(OUT,">$out");}
while(<IN1>){
    my $f1_1=$_;$f1_1=~s/^\@//;$f1_1=(split/\s+/,$f1_1)[0]; my $f1_2=<IN1>;<IN1>;<IN1>;
    my $f2_1=<IN2>;$f2_1=~s/^\@//;$f2_1=(split/\s+/,$f2_1)[0]; my $f2_2=<IN2>;<IN2>;<IN2>;
    if($_!~ /\/\d$/){
	#print "new"
        print OUT ">$f1_1/1\n$f1_2>$f2_1/2\n$f2_2";
	}
    else{
	#print "old"
        print OUT ">$f1_1\n$f1_2>$f2_1\n$f2_2";
        }
}
close IN1;close IN2;close OUT;

