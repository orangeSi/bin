#!/usr/bin/perl -w

die "
perl $0 <seq.fa.list> <list of keyword> <prefix of output>
" if(@ARGV!=3);
my $seqList=shift;
my $list=shift;
my $pre=shift;

my %lists;
open LIST,"$list" or die "$!";
while(my $k=<LIST>){
	chomp $k;
	$lists{$k}="";
}
close LIST;

foreach my $seq(`cat $seqList`){
	chomp $seq;
	my $base=`basename $seq`;
	$base=~ s/\s*$//g;
	open IN,"$seq" or die "$!";
	print "writing $pre.$base.fa\n";
	$/=">";
        open OUT,">$pre.$base.fa" or die "$!";
	while(<IN>){
		chomp;
		next if(!$_);
		my @arr=split(/\n/,$_,2);
		if(!$arr[1]){die "is $_\n";}
		my $flag=0;
		foreach my $k(keys %lists){
			if($arr[0]=~ /$k/i){
				$flag++;
				last
			}
		}
		if(!$flag){
			print OUT ">$arr[0]\n$arr[1]";
		}
	}
	close IN;
	close OUT;
}
