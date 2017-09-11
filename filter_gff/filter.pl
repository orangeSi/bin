#!/usr/bin/perl -w
open  RAW,"W303_JRIU00000000_SGD.gff.filter1" or die "$!";
my $geneid;
my $cdsid;
my $index;
while(<RAW>){
	chomp;
	my @arr=split(/\t/,$_);
	next if($arr[2] ne "gene" && $arr[2] ne "CDS" );
	if($arr[2] eq "gene"){
		$arr[-1]=~ /^([^,]+),/;
		$geneid=$1;
		$geneid="gene$index" if(!$geneid);
		print join("\t",@arr[0..(scalar @arr -2)]),"\tID=$geneid;\n";
	}else{
		$index++;
		$arr[-1]=~ /^([^,]+),/;
		$cdsid=$1;
		$cdsid="cds$index" if(!$cdsid);
		print 	join("\t",@arr[0..(scalar @arr -2)]),"\tID=$cdsid\_cds$index;Parent=$geneid;\n";
	}

}
close RAW;
