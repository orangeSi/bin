#!/usr/bin/perl -w


my $cds=shift;
my $out=shift;

open IN,"$cds" or die "$!";
open OUT,">$out" or die "$!";
$/=">";
<IN>;
while(<IN>){
	chomp;
	my ($name,$seq)=split(/\n/,$_,2);
	$seq=~ s/\s+//g;
	if($seq=~ /^ATG/){
		print OUT ">$name\n$seq\n";
	}elsif($seq=~ /CAT$/){
		$seq=reverse($seq);
		$seq=~ tr/ATCG/TAGC/;
		print OUT ">$name\n$seq\n";
	}else{
		print "error!id is $name\n";
	}

}
close IN;
close OUT;
