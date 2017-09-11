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
	$k=~ s/\s*$//g;
	$lists{$k}="";
}
close LIST;

foreach my $seq(`cat $seqList`){
	chomp $seq;
	my $base=`basename $seq`;
	$base=~ s/\s*$//g;
	open IN,"$seq" or die "$!";
	print "writing $pre.$base\n";
        open OUT,">$pre.$base" or die "$!";
	while(<IN>){
		chomp;
		my $flag=0;
		foreach my $kk(keys %lists){
			if($_=~ /$kk/){
				$flag++;
			}
		}

		if($flag ==0){
			print OUT "$_\n";
		}
	}
	close IN;
	close OUT;
}
