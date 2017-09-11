#!/usr/bin/perl -w
die "perl $0 <input.fasta> <top total length;bp> <prefix of output>
get longest <top>bp from input.fasta \n" if(@ARGV!=3);

my $in=shift;
my $total=shift;
my $pre=shift;

my %seqs;
#`fastalength $in >$in.len`;
open IN,"$in" or die "$!";
$/=">";
<IN>;
while(<IN>){
	chomp;
	my @arr=split(/\n/,$_,2);
	$arr[0]=~ s/^(\S+)\s+.*$/$1/;
	$arr[1]=~ s/\s+//g;
	my $len=length $arr[1];
	$seqs{$arr[0]}{len}=$len;
	$seqs{$arr[0]}{seq}=$arr[1];
}
close IN;
my $flag;
open OUT,">$pre" or die "$!";
foreach my $k(sort {$seqs{$b}{len}<=>$seqs{$a}{len}} keys %seqs){
	$flag+=$seqs{$k}{len};
	print OUT ">$k\n$seqs{$k}{seq}\n";		
	if($flag>$total){
		last
	}
}
close OUT;
