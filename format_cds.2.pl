#!/usr/bin/perl -w

die "<cds.fa> <genome.fa> <outfile>" unless(@ARGV==3);
my $cds=shift;
my $genome=shift;
my $out=shift;


my $genome=`cat $genome|awk '{if(\$0!~ /^>/){print \$0}}'`;
chomp $genome;
die "genome is $genome\n";
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
