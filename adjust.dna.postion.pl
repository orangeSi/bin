#!/usr/bin/perl -w

die "perl $0 <input.fa> <contig id list for adjust;format:id dnaA_start> <out> ,dna startis form 1 ,not 0;\n" if(@ARGV!=3);

my $in=shift;
my $id=shift;
my $out=shift;

my %ids;
open ID,"$id" or die "$!";
while(<ID>){
	chomp;
	my ($id,$start)=split(/\s+/);
	$ids{$id}{start}=$start;

}
close ID;

open IN,"$in" or die "$!";
open OUT,">$out" or die "$!";
$/=">";<IN>;
while(<IN>){
	chomp;
	my @arr=split(/\n/,$_,2);
	$arr[0]=~ /^(\S+)/;
	my $id=$1;
	if(exists $ids{$id}){
		$arr[1]=~ s/\s//g;
		my $start=$ids{$id}{start};
		my $head=substr($arr[1],$start -1);
		my $tail=substr($arr[1],0,$start -1);
		print OUT ">$arr[0]\n${head}$tail\n";
	}else{
		print OUT ">$arr[0]\n$arr[1]\n";
	}
}
close IN;
close OUT;
