#!/usr/bin/perl -w
if(@ARGV!=1){print "perl $0 <fastq file>\n\n";exit}
use PerlIO::gzip;

my $i=0;
open IN,"<:gzip(autopop)","$ARGV[0]" or die "$!";
#open OUT,">$ARGV[0].tmp"or die "$!";
my $str;
while(<IN>){
	chomp;
	my $id=$_;
	my $seq=<IN>;
	<IN>;
	my $qv=<IN>;
	chomp  $qv;
	if($i<10000){
#print OUT "$id\n$seq+\n$qv";
		$str.=$qv;
	}else{
		last;
	}
	$i++;
}
close IN;
#close OUT;
my @arr=split(//,$str);
my $min=100;
foreach my $k(@arr){
	my $tmp=ord($k);
	if($tmp < $min){$min=$tmp}

}
print "min of $ARGV[0] is $min\n"
