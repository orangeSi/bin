## read kegg 
my $kegg ="/ifshk5/BC_COM_P8/F17FTSSCKF0402/CROtgrD/outdir/Upload/BGI_result/Separate/CSF/4.Genome_Function/General_Gene_Annotation/CSF.kegg.list.anno.xls";

my $rawgb="/ifshk5/BC_COM_P8/F17FTSSCKF0402/CROtgrD/outdir/Upload/BGI_result/Separate/CSF/2.Assembly/CSF.genome.gb";
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
while(<GB>){
	chomp;
	if($_!~ /locus_tag/){
		print "$_\n";
	}else{
			$_=~/locus_tag="(.*)"/;
			my $gene=$1;
			
			if($name{$gene}){
				print "                     /gene=\"$name{$gene}\"\n";
			}
			
			print "$_\n";
	}

}
close GB;
