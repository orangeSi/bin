#!/usr/bin/perl -w
if(@ARGV!=4){
	print "perl $0 <input fasta> <id> <start> <end> start or end is from 0 ,not 1\n\n";	
	exit
	}

my $in=shift;
my $id=shift;
my $s=shift;
my $e=shift;


open IN,"$in" or die "$!";
$/=">";
<IN>;
open OUT,">$id\_$s\_$e.fasta" or die "$!";
while(<IN>){
	chomp;
	my @arr=split(/\n/,$_,2);
	$arr[0]=~ /^(\S+)/;
	if($1 eq $id ){
		$arr[1]=~ s/\s+//g;
		my $tmp=substr($arr[1],$s,$e -$s+1);
		print OUT ">$arr[0]\_$s\_$e\_\n$tmp\n";
		}
	
	}

close IN;
close OUT;

