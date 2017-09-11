#!/usr/bin/perl -w
use Getopt::Long;
use PerlIO::gzip;
my ($pe,$se,$r1,$r2,$flag,$pre,$outdir);
GetOptions("pe:s"=>\$pe,
	   "se:s"=>\$se,
	   "r1:s"=>\$r1,
	   "r2:s"=>\$r2,
	   "flag:i"=>\$flag,
	   "prefix:s"=>\$pre,
	   "outdir:s"=>\$outdir,
);
my $usage="
usage: perl $0 [options]

[options]:
	--pe<str> 	 soap.pe.gz or not gz
	--se<str> 	 soap.se.gz or not gz
	--r1<str>	 read1.fq.gz or not gz
	--r2<str> 	 read2.fq.gz or not gz
	--flag<1 or 2>   1:fetch r1&r2 for se ; 2:only fetch r1|r2 for se
	--prefix<str> 	 prefix of output
	--outdir<str> 	 outdir

write by myth 2016-11-10
";
die "$usage" unless($r1 && $r2 && $flag && $pre && $outdir);

`mkdir -p $outdir` if (! -e $outdir);
my %lists;
open PE,"<:gzip(autopop)","$pe" or die "$!";
while(<PE>){
	chomp;
	if($_=~ /^#/ ){next}
	$_=~ /^(\S+)/;
	my $id=$1;
	if($id!~ /\/[12]$/){die "/1 or /2 should be the end of read id"}
	$lists{"$id"}="";

}
close PE;
if($se){
	open SE,"<:gzip(autopop)","$se" or die "$!";
	while(<SE>){
		chomp;
		if($_=~ /^#/){next}
		$_=~ /^(\S+)/;
		my $id=$1;
		#$id=~ s/\/(\d)$/_$1/;
		if($flag == 1){
			$lists{"$id"}="";
			if($id=~ /\/1$/){
				$id=~ s/\/1$/\/2/;
			}elsif($id=~ /\/2$/){
				$id=~ s/\/2$/\/1/;
			}

			$lists{"$id"}="";
		}
	}
	close SE;

}


	

my $index=1;
if($flag == 2){open SE,"|gzip >$outdir/$pre.se.fetched.fq.gz" or die "$!";}
foreach my $k($r1,$r2){
	if($index ==1){open R1,"|gzip >$outdir/$pre.r1.fetched.fq.gz" or die "$!";}else{open R2,"|gzip >$outdir/$pre.r2.fetched.fq.gz" or die "$!";}
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
				print SE "\@$id\n$seq\n$tag\n$qv\n";
			}
		}
			
		
	}
	close RE;
	if($index==1){close R1}else{close R2}

	$index++;

}
close SE
