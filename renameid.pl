#!/usr/bin/perl -w
if(@ARGV!=3){
	print "\nperl $0 <subread.fa or gz> <prefix of outputfile> <0 or 1;different movie flag>
	this scipt will rename id ,so for same one ZMW,have different ids.\n\n";
	exit
}
my $raw=shift;
my $pre=shift;
my $flag=shift;

my $tmp1="m150314_133943_42228_c100791642550000001823175909091590_s1_p0";
my $tmp2="m160314_133943_42228_c100791642550000001823175909091590_s1_p0";


my $index;
if($raw=~ /.gz$/){
	open IN,"gzip -dc $raw|" or die "$!";
}else{
	open IN,"$raw" or die "$!";
	}
my $tmp=`dirname $pre`;
chomp $tmp;
if(! -d "$tmp"){`mkdir -p $tmp`}
open Q,">$pre.rename.subread.fasta" or die "$!";
$/=">";
<IN>;
while(<IN>){
	chomp;
	$index++;
	my @arr=split(/\n/,$_,2);
	my $tmp;
	if($flag){$tmp=$tmp1}else{$tmp=$tmp2}
	$arr[0]=~ s/^.*\/\d+\//$tmp\/$index\//;
	print Q ">$arr[0]\n$arr[1]";



}
close IN;
close Q;
