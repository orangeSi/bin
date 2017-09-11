#!/usr/bin/perl -w

die "
perl $0 <seq.fa> <list of keyword> <prefix of output> rm sequence from list
" if(@ARGV!=3);
my $seq=shift;
my $list=shift;
my $pre=shift;

my %lists;

foreach my $k(`cat $list`){
	chomp $k;
	my @tmp=split(/\s+/,$k);
	$lists{$tmp[0]}="";
}
open IN,"$seq" or die "$!";
$/=">";<IN>;
open OUT,">$pre.keep.fa" or die "$!";
while(<IN>){
	chomp;
	my @arr=split(/\n/,$_,2);
	$arr[0]=~ /^(\S+)/;
	my $id=$1;
	if(! exists $lists{$id}){
		print OUT ">$arr[0]\n$arr[1]";
	}
}
close IN;
close OUT;

