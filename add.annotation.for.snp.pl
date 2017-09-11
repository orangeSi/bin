#!/usr/bin/perl -w

die "perl $0 <anno.xls> <*.snp> <outfile>\n" if(@ARGV!=3);

my $anno=shift;
my $snp=shift;
my $out=shift;

my %annos;
open IN,"$anno" or die "$!";
my $line=<IN>;
my ($title,$types)=split(/\t/,$line,2);
$types=~ s/{|}//g;
while(<IN>){
	chomp;
	my ($id,$an)=split(/\t/,$_,2);
	$annos{$id}=$an;
	#print "is $id,line is $_\n";
	#if($id eq "KNP414_RS04535"){print "KNP414_RS04535 is $_\n"}
}
close IN;

open IN,"$snp" or die "$!";
$line=<IN>;
chomp $line;
open OUT,">$out" or die "$!";
print OUT "$line\t$types";
while(<IN>){
	chomp;
	my @arr=split(/\t/,$_);
	if(exists $annos{$arr[10]}){
		print OUT "$_\t$annos{$arr[10]}\n";
	}else{
		print OUT "$_\tnull\n";
	}

}
close IN;
close OUT;
