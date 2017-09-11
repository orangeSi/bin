#!/usr/bin/perl -w
use Getopt::Long;
use PerlIO::gzip;
use File::Path;
use File::Basename qw(basename);

my ($keep_length,$Outdir,$in1,$in2);
GetOptions(
	"keep_length:s"    => \$keep_length,
	"outdir:s"            => \$Outdir,
	"r1:s"		  => \$in1,
	"r2:s"		  => \$in2,
);

die "
perl $0 
	--keep_length length
	--outdir *
	--r1 *
	--r2 *

" unless ($in1 && $in2 && $Outdir);

mkpath $Outdir unless ( -e $Outdir);
my $index=0;
my %r1;
my %r2;
my %fail;

foreach my $k ($keep_length,$keep_length){
	
	if($k){
		my $length=$k;
		my $read=($index)? $in2:$in1;
		my $name=basename($read);
		if($name!~/\.gz$/){$name.=".gz";}
		open RE,"<:gzip(autopop)","$read" or die "$!";
		open OUT,">$Outdir/$name" or die "$!";
		while(<RE>){
			chomp;
			my $id=$_;
			my $seq=<RE>;chomp $seq;
			my $tag=<RE>;chomp $tag;
			my $qv=<RE>;chomp $qv;
			my @arr=$seq=~ /([^N]+)/g;
			my $len=0;
			my $SEQ;
			foreach my $block(@arr){
				my $l=length $block;
				if($l>$len){$len=$l;$SEQ=$block;}
			}
			if($len>=$length){
				my $seq_new=substr($SEQ,0,$length);
				my $qv_new=substr($qv,0,$length);
				print OUT "$id\n$seq_new\n$tag\n$qv_new\n";

			}else{
				$id=~ /^(.*)\d$/;
				$fail{$1}="";
			}

			
		
		}
		close RE;
		close OUT;
		print "$name\n";
	}
	$index ++;

}

$index=0;
foreach my $k ($keep_length,$keep_length){
	
	if($k){
		my $length=$k;
		my $read=($index)? $in2:$in1;
		my $name=basename($read);
		if($name!~/\.gz$/){$name.=".gz";}
		open RE,"$Outdir/$name" or die "$!";
		open OUT,"|gzip >$Outdir/final.$name" or die "$!";
		while(<RE>){
			chomp;
			my $id=$_;
			my $seq=<RE>;chomp $seq;
			my $tag=<RE>;chomp $tag;
			my $qv=<RE>;chomp $qv;
			$id=~ /^(.*)\d$/;
			if(! exists $fail{$1}){
				print OUT "$id\n$seq\n$tag\n$qv\n";
			}
			


			
		
		}
		close RE;
		close OUT;
		print "$name\n";
	}
	$index ++;

}

