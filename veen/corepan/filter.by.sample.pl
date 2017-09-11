#!/usr/bin/perl -w

die "perl $0 <keeped.sample.list,less than 5> <PanGene.matrix> <output>\n" if(@ARGV!=3);

my $list=shift;
my $pan=shift;
my $out=shift;


my %keep;
my %pass;
my $list_index;
my $name_list;
open MAP,">$out.Mapping.txt" or die "!";
open MAPG,">$out.name.list" or die "!";
print MAP "#SampleID	Description\n";
foreach my $k(`cat $list`){
	$list_index++;
	chomp $k;
	$keep{$k}="";
	print MAP "$k\t\n";
	$name_list.="$k:";

}
	$name_list=~ s/:$//;
	print MAPG "$name_list\n";
close MAPG;
close MAP;
if($list_index >5){die "keep less than 5 samples,please modify your file $list\n"}
open IN,"$pan" or die "$!";
open OUT,">$out" or die "$!";
my $head=<IN>;chomp $head;
my @arr=split(/\t+/,$head);
my $index=0;
#print OUT "$head\n";
my $header;
shift @arr;
foreach my $k(@arr){
	chomp $k;
	if(!exists $keep{$k}){
		$pass{$index}="";
	}else{
		$header.="$k\t";
	}
	$index++;
}
$header="\t$header";
$header=~ s/\t$/\n/;
print OUT "$header";
while(<IN>){
	chomp;
	@arr=split(/\t+/,$_);
	$index=0;
	my $line;
	my $flag;
	my $h=shift @arr;
	foreach my $k(@arr){
		chomp $k;
		if(!exists $pass{$index}){
			$line.="$k\t";
			$flag+=$k;
		}
		$index++;
	}
	$line="$h\t$line";
	$line=~ s/\t$/\n/;

	print OUT "$line" if($flag >0);

}
	
close IN;
close OUT;
