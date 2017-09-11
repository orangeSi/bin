#!/usr/bin/perl -w
if(@ARGV!=3){
	print "perl $0 <list> <reads.fq.gz> <prefix of output>\n\n";
	exit
}

my $list=shift;
my $raw=shift;
my $pre=shift;


my %lists;
foreach (`cat $list`){
	chomp;
	if($_=~ /^#/){next}
	$_=~ /^(\S+)/;
	my $id=$1;
	$lists{$id}="";

}
open R1,"|gzip >$pre.fetched.fq.gz" or die "$!";
open RE,"$raw" or die "$!";
while(<RE>){
	chomp;
	my $id=$_;
	my $seq=<RE>;
	my $tag=<RE>;
	my $qv=<RE>;
	chomp $seq;
	chomp $tag;
	chomp $qv;
	$id=~ s/^@//;
	if(exists $lists{$id}){
		print R1 "\@$id\n$seq\n$tag\n$qv\n";

	}
}
close RE;
close R1;

