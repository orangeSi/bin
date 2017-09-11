#!/usr/bin/perl -w
use Getopt::Long;
use PerlIO::gzip;
use File::Path;
use File::Basename qw(basename);

my ($R1_keep_region,$R2_keep_region,$Outdir,$in1,$in2);
GetOptions(
	"R1_keep_region:s"    => \$R1_keep_region,
	"R2_keep_region:s"    => \$R2_keep_region,
	"outdir:s"            => \$Outdir,
	"r1:s"		  => \$in1,
	"r2:s"		  => \$in2,
);

die "
perl $0 
	--R1_keep_region start:length(for substr(,start-1,length)),start if from 1;
	--R2_keep_region start:length(for substr(,start-1,length)),start if from 1; 
	--outdir *
	--r1 *
	--r2 *

" unless ($in1 && $in2 && $Outdir);

mkpath $Outdir unless ( -e $Outdir);
my $index=0;
foreach my $k ($R1_keep_region,$R2_keep_region){
	
	if($k){
		$k=~ /^(\d+):(\d+)/;
		my ($start,$length)=($1,$2);
		my $read=($index)? $in2:$in1;
		my $name=basename($read);
		if($name!~/\.gz$/){$name.=".gz";}
		open RE,"<:gzip(autopop)","$read" or die "$!";
		open OUT,"|gzip >$Outdir/$name" or die "$!";;
		while(<RE>){
			chomp;
			my $id=$_;
			my $seq=<RE>;chomp $seq;
			my $tag=<RE>;chomp $tag;
			my $qv=<RE>;chomp $qv;
			my $seq_new=substr($seq,$start -1,$length);
			my $qv_new=substr($qv,$start -1,$length);
			print OUT "$id\n$seq_new\n$tag\n$qv_new\n";

			
		
		}
		close RE;
		close OUT;
	}
	$index ++;

}

