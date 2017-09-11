#!/usr/bin/perl -
die "perl $0 <pep or cds.list>\n" if(@ARGV!=1);

my $list=shift;

open IN,"$list" or die "$!";
while(<IN>){
	chomp;
	my $flag;
	my $list=$_;
	open CDS,"$list" or die "$!";
	open OUT,">$list.new" or die "$!";

	$/=">";
	<CDS>;
	while(<CDS>){
		chomp;
		my @arr=split(/\n/,$_,2);
		$arr[1]=~ s/\s+//g;
		if(!$arr[1]){next}
		$arr[0]=~ s/\t/ /g;
		if($arr[0]!~ /^(\S+)/){
			if($arr[0]=~ /^\s+(\S+)/){
				my $id=$1;
				print OUT ">$id\n$arr[1]\n";
			}else{
				die "$. $list\n";
			}	
			$flag++;
		}else{
			$arr[0]=~ /^(\S+)/;
			print OUT ">$1\n$arr[1]\n";
		}
			
		
	}
	close CDS;
	close OUT;
	$/="\n";
	if($flag){print "$list\n";}
}
close IN;

