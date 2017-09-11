#!/usr/bin/perl -w
use Getopt::Long;
use PerlIO::gzip;
my ($r1m6,$r2m6,$r1,$r2,$flag,$pre,$outdir,$indentity,$coverage);
GetOptions("r1m6:s"=>\$r1m6,
	   "r2m6:s"=>\$r2m6,
	   "r1:s"=>\$r1,
	   "r2:s"=>\$r2,
	   "flag:i"=>\$flag,
	   "prefix:s"=>\$pre,
	   "outdir:s"=>\$outdir,
	   "indentity:i"=>\$indentity,
	   "min_aln_length:i"=>\$coverage,

);
my $usage="
usage: perl $0 [options]

[options]:
	--r1m6<str> 	 	r1.blast.m6.gz or not gz
	--r2m6<str> 	 	r2.blast.m6.gz or not gz
	--r1<str>	 	read1.fq.gz or not gz
	--r2<str> 	 	read2.fq.gz or not gz
	--flag<1 or 2>   	1:fetch r1&r2 for se ; 2:only fetch r1|r2 for se
	--prefix<str> 	 	prefix of output
	--outdir<str> 	    	outdir
	--indentity<i>      	for blast aln 
	--min_aln_length<i> 	for blast aln length of read

write by myth 2016-11-10
";
die "$usage" unless($r1 && $r2 && $flag && $pre && $outdir && $coverage && $indentity);

`mkdir -p $outdir` if (! -e $outdir);
my %lists;
foreach my $k($r1m6,$r2m6){
open M6,"<:gzip(autopop)","$k" or die "$!";
open OUT,">$k.filter.$indentity.$coverage.m6" or die "$!";
while(<M6>){
	chomp;
	if($_=~ /^#/){next}
	my @arr=split(/\t/,$_);
	if($arr[0]!~ /\/[12]$/){die "error format of reads id,should be end with /1 or /2\n"}
	next if($arr[2] <$indentity || $arr[3] <$coverage);
	print OUT "$_\n";
	my $id=$arr[0];
	$lists{"$id"}="";
	if($flag == 1){
		my $id2=$id;
		if($id=~ /\/1$/){
			$id2=~ s/\/1$/\/2/;
			$lists{"$id2"}="";
			
		}elsif($id=~ /\/2$/){
			$id2=~ s/\/2$/\/1/;
			$lists{$id2}="";
		}else{
			die "unsupported reads id format~\n";
		}
	}

}
close M6;
close OUT;
}




my $index=1;
if($flag == 2){open SE,"|gzip >$outdir/$pre.$indentity.$coverage.se.blast.fq.gz" or die "$!";}
foreach my $k($r1,$r2){
	if($index ==1){open R1,"|gzip >$outdir/$pre.$indentity.$coverage.r1.blast.fq.gz" or die "$!";}else{open R2,"|gzip >$outdir/$pre.$indentity.$coverage.r2.blast.fq.gz" or die "$!";}
	open RE,"<:gzip(autopop)","$k" or die "$!";
	while(<RE>){
		chomp;
		my $seq=<RE>;
		my $tag=<RE>;
		my $qv=<RE>;
		chomp $seq;
		chomp $tag;
		chomp $qv;
		$_=~ /^(\S+)/;
		my $id=$1;
		$id=~ s/^@//;
#		$id=~ s/\/(\d)$/_$1/;
		my $id2=$id;
		if($index ==1){
			$id2=~ s/\/1$/\/2/;
		}else{
			$id2=~ s/\/2$/\/1/;
		}
		#print "id is $id\nid2 is $id2\n";
		if(exists $lists{"$id"}){
			if(exists $lists{"$id2"}){
				if($index ==1){	print R1 "\@$id\n$seq\n$tag\n$qv\n";}else{print R2 "\@$id\n$seq\n$tag\n$qv\n";}
			}else{
				#print "se id is $id $id2\n";
				print SE "\@$id\n$seq\n$tag\n$qv\n";
			}
		}
			
		
	}
	close RE;
	if($index==1){close R1}else{close R2}

	$index++;

}
close SE
