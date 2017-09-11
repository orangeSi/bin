#!/usr/bin/perl -w
die "perl $0 <genome.list> <outdir>\n" unless(@ARGV == 2);
my $list=shift;
my $outdir=shift;

`mkdir -p $outdir`;

foreach my $k(`cat $list`){
	chomp $k;
	my $base=`basename $k`;
	$base=~ s/\s+$//g;
	open IN,"$k" or die "$!";
	open OUT,">$outdir/$base" or die "$!";
	$/=">";<IN>;
	while(<IN>){
		chomp;
		my @arr=split(/\n/,$_,2);
		$arr[0]=~ /^(\S+)/;
		my $id=$1;
		$id=~ s/\|/:/g;
		print OUT ">$id\n$arr[1]\n";


	
	}
	print "$outdir/$base\n";
	close IN;
	close OUT;
}
