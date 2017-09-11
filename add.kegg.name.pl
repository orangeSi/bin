## read kegg 
my $kegg ="/ifshk5/BC_COM_P8/F17FTSSCKF0402/CROtgrD/outdir/Upload/BGI_result/Separate/CSF/4.Genome_Function/General_Gene_Annotation/CSF.kegg.list.anno.xls";

my $rawgb="CSF.annotation.table.xls";
my %name;
open KEGG,"$kegg" or die "$!";
while(<KEGG>){
	chomp;
	my @arr=split(/\t/,$_);
	$arr[3]=~ /([^:]*):.*/;
	$name{$arr[0]}=$1;

}
close KEGG;

my $flag;
open GB,"$rawgb" or die "$!";
my $header=<GB>;chomp $header;
print "$header\n";
while(<GB>){
	chomp;
	my @arr=split(/\t/,$_);
	if($arr[2] !~ "{NA}"){
		die "die" if(! exists $name{$arr[0]});
		my $tmp=$name{$arr[0]};
		$arr[2]=~ s/^{/{ $tmp /;
		my $str=join("\t",@arr);
		chomp $str;
		print "$str\n"
	}else{
		print "$_\n"
	}
}
close GB;
