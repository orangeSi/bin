#!/usr/bin/perl

=head1 Name

make_ncbi_tbl.pl  --  make tbl files for NCBI submission

=head1 Description

read from a set of files: parameter.paml, gene.gff and related combined.annotation,tRNA files, rRNA files.

Do not consider UTR region in this version, that would be future work.

=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  updata by Wang Shuang
  Version: 2.0,  Date: 2011-10-10
  Note:

=head1 Usage

  perl make_ncbi_tbl.pl <options>
  --sample	   set sample name
  --species	   set species name[default:bacteria]
  --template	   set template file[default:$Bin/template.sbt]
  --outdir         set outdir 
  --parameter      set parameter yaml file
  --genome         set genome.fa 
  --gene           set gene gff file after filtet by Check_Data_NCBI.pl
  --annotation     set the combined annotation file by Check_Data_NCBI.pl
  --swissprot	   set the DependableDescription.lst by Check_Data_NCBI.pl
  --tRNA           set tRNA gff file after filter by Check_Data_NCBI.pl
  --rRNA           set rRNA gff file after filter by Check_Data_NCBI.pl
  --verbose        output running progress information to screen  
  --tbl2asn        set tbl2asn program[default:$Bin/tbl2asn]
  --help           output help information to screen  
=cut

use strict;
use Getopt::Long;
use File::Path;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;
use YAML qw(Load Dump);

##get options from command line into variables and set default values
my ($Outdir,$Verbose,$Help,$Parameter_file,$genome_file,$Gene_file,$Annotation_file,$swissprot,$tRNA_file,$rRNA_file,$sample,$tbl2asn,$species,$template,$kegg);
GetOptions(
	"parameter:s"=>\$Parameter_file,
	"genome:s"=>\$genome_file,
	"gene:s"=>\$Gene_file,
	"annotation:s"=>\$Annotation_file,
	"swissprot:s"=>\$swissprot,
	"tRNA:s"=>\$tRNA_file,
	"rRNA:s"=>\$rRNA_file,
	"outdir:s"=>\$Outdir,
	"sample:s"=>\$sample,
	"template:s"=>\$template,
	"tbl2asn:s"=>\$tbl2asn,
	"template:s"=>\$template,
	"species:s"=>\$species,
	"kegg:s"=>\$kegg,
	"verbose"=>\$Verbose,
	"help"=>\$Help
);
$Outdir ||= ".";
$Outdir = "$Outdir/output";mkpath $Outdir;
$tbl2asn ||= "$Bin/tbl2asn";
$template ||= "$Bin/template.sbt";
$species ||= "bacteria";
die `pod2text $0` if (defined $Help  || !$Gene_file );

my %Gene;
my %Anno;
my $total_gene_number;
my $Out_Gene_Locus;
my $Parameter;

my %swissprot;
if(defined $swissprot){
	open(IN,$swissprot)||die `Can't open DependableDescription.lst file \n`;
	while(<IN>){
		chomp;
		my @cut=split /\t/;
		$swissprot{$cut[0]}=$cut[1];
		print $_,"\n" unless $cut[1];
	}
	close IN;
}
	
##read parameter file
if (defined $Parameter_file) {
	open IN, $Parameter_file || die "fail open Parameter_file $Parameter_file \n";
	$Parameter = Load( join("", <IN>) );
	close IN;
}

##read genome file
my %sample;
open(IN, $genome_file) || die ("can not open genome_file $genome_file\n");
$/=">"; <IN>;
while(<IN>){
	chomp;
	my @line = split /\n/;
	my @temp = split /\s+/,$line[0];
	my $chr = $temp[0];
	my $type;
	if($line[0] =~ /circular/){
		$type = "[topology=circular] [completeness=complete] ";
	}elsif($line[0] =~ /linear/){
		$type = "[topology=linear]";
	}else{
		$type = "[topology=linear]";
	}
	shift @line;
	my $seq = join "",@line;
	$seq =~ s/\s+//g;
	$sample{$chr}=$seq;
	open OUT, ">$Outdir/$chr.fsa" || die "fail creat $Outdir/$chr.fsa";
	print OUT ">$chr"." [organism=".$Parameter->{organism}."] [strain=".$Parameter->{strain}."] [gcode=".$Parameter->{gcode}."] $type \n", $seq;
	close OUT;
}
close(IN);
$/ ="\n";
##read gene gff file
my %AS;
if (defined $Gene_file) {
	open (IN,$Gene_file) || die ("fail open Gene_file $Gene_file\n");
	while (<IN>) {
        	if (/^#/){next;}
			s/^\s+//;
			my @t = split(/\t/);
			my $tname = $t[0];
			my $qname = $1 if($t[8] =~ /^ID=(\S+?);/ || $t[8] =~ /^Parent=(\S+?);/);
		if ($t[2] eq 'mRNA' ) {
			push @{$Gene{$tname}}, ["gene",$qname,$t[3],$t[4],"mRNA",$t[6]];
			push @{$AS{$qname}{mRNA}},[$t[3],$t[4],$t[6]];
			$total_gene_number++;
		}
		if ($t[2] eq 'CDS') {
			push @{$Anno{$qname}{cds}},[$t[3],$t[4]];
		}
	}
	close(IN);
}
my %name;

## read kegg 
open KEGG,"$kegg" or die "$!";
while(<KEGG>){
	chomp;
	my @arr=split(/\t/,$_);
	$arr[3]=~ /(.*):.*/;
	$name{$arr[0]}=$1;

}
close KEGG;

##read gene annotation file
if (defined $Annotation_file) {
	open(IN, $Annotation_file) || die ("can not open Combine_Annotation $Annotation_file\n");
	$/=">"; <IN>; $/="\n";
	while (<IN>) {
		my $gene = $1 if(/^(\S+)/);
		$/=">";
		my $anno_str = <IN>;
		chomp $anno_str;
		$/="\n";
		my @anno = split /\n/, $anno_str;
		foreach  my $database ( @anno ) {
			my @temp = split /\t/,$database;
			my $type =shift @temp;
			if($type =~ /RefSeq/){
				my $info = join " ",@temp;
				push @{$Anno{$gene}{$type}},$info;
			}
			if($type =~ /Swissprot/){
				my $info = join " ",@temp;
				push @{$Anno{$gene}{$type}},$info;
			}
			if($type =~ /TrEMBL/){
				my $info = join " ",@temp;
				push @{$Anno{$gene}{$type}},$info;
			}
			if($type =~ /COG/){
				my $info = join " ",@temp;
				push @{$Anno{$gene}{$type}},$info;
			}
			if($type =~ /KEGG/){
				if($temp[2]){
					#$name{$gene}=
					my $EC_number = pop @temp;
					push @{$Anno{$gene}{"EC_number"}},$EC_number;
				}
				my $info = join " ",@temp;
				push @{$Anno{$gene}{$type}},$info;
			}
			if($type =~ /GO/){
				foreach my $temp (@temp){
					next if $temp eq "";
					my @t = split /;/,$temp;
					$t[0] =~ s/^\s+//g;
					$t[0] =~ s/\s+$//g;
					if($t[1] =~ /molecular_function/){
						push @{$Anno{$gene}{"go_function"}},$t[0];
					}
					if($t[1] =~ /biological_process/){
						push @{$Anno{$gene}{"go_process"}},$t[0];
					}
					if($t[1] =~ /cellular_component/){
						push @{$Anno{$gene}{"go_component"}},$t[0];
					}
				}
			}
		}
	}
	close(IN);
}

##read tRNA file
if (defined $tRNA_file) {
	open (IN,$tRNA_file) || die ("fail open tRNA_file $tRNA_file\n");
	while (<IN>) {
		if (/#/){next};	
		s/^\s+//;
		my @t = split(/\t/);
		my $tname = $t[0];
		my $qname = $1 if($t[8] =~ /^ID=(\S+?);/ || $t[8] =~ /^Parent=(\S+?);/);
		my $product = $1 if($t[8] =~ /Type=(\w+);/);
		$Anno{$qname}{product} = ($product ne "Pseudo") ? $product : "Xxx";
		$Anno{$qname}{product} = ($product ne "Undet") ? $product : "Xxx";
		push @{$Gene{$tname}}, ["tRNA",$qname,$t[3],$t[4],"tRNA",$t[6]];
		$total_gene_number++;
		
	}
	close(IN);
}

##read rRNA file
if (defined $rRNA_file) {
	my $number++;
	open (IN,$rRNA_file) || die ("fail open rRNA_file $rRNA_file\n");
	while (<IN>) {
		if (/#/){next};
		s/^\s+//;
		my @t = split(/\t/);
		my $tname = $t[0];
		my $qname = $1 if($t[8] =~ /(.*\d+s_rRNA)/);
		push @{$Gene{$tname}}, ["rRNA",$qname,$t[3],$t[4],"rRNA",$t[6]];

		$total_gene_number++;
	}
	close(IN);
}

##make tbl file
my $Locus_mark = number_to_mark($total_gene_number);
foreach my $chr (sort keys %Gene) {
	my $output = ">Feature "."$chr\n";
	my $chr_p = $Gene{$chr};	
	foreach my $gene_p (sort {$a->[2] <=> $b->[2]} @$chr_p) {
		my $gene = $gene_p->[1];
		my $Locus_tag = $Parameter->{locus_tag_prefix}.'_'.$Locus_mark;
		$Out_Gene_Locus .= "$gene\t$Locus_tag\n";
		
		##deal with tRNi
		if ($gene_p->[0] eq "tRNA") {
			my $product = "tRNA-$Anno{$gene}{product}";
			$output .= "$gene_p->[2]\t$gene_p->[3]\tgene\n\t\t\tlocus_tag\t$gene_p->[1]\n";
			$output .= "$gene_p->[2]\t$gene_p->[3]\ttRNA\n\t\t\tproduct\t$product\n";
			$Locus_mark++;
		}
		
		##deal with rRNA
		if ($gene_p->[0] eq "rRNA") {
       		    my $product = "$1S ribosomal RNA" if($gene_p->[1] =~ /(\d+)/);
			$output .= "$gene_p->[2]\t$gene_p->[3]\tgene\n\t\t\tlocus_tag\t$gene_p->[1]\n";
			$output .= "$gene_p->[2]\t$gene_p->[3]\trRNA\n\t\t\tproduct\t$product\n";
			$Locus_mark++;
		}
		
		##deal with protein coding gene
		next if($gene_p->[0] ne "gene");
		my @cds = @{$Anno{$gene}{cds}}; 
		@cds = reverse @cds if($cds[0][0] > $cds[-1][0]);
		my $strand = $gene_p->[5];
		
		if ($strand eq '-') {
			@cds = reverse @cds;
			foreach my $p (@cds) {
				($p->[0],$p->[1]) = ($p->[1],$p->[0]);
			}
		}
############### gene
		my $gene_feture;
	        my $CDS_feature;
		my $mRNA_feature;
		$gene_feture = "$cds[0][0]\t$cds[-1][1]\tgene\n\t\t\tgene=\"$name{$gene_p->[1]}\"\n\t\t\tlocus_tag\t$gene_p->[1]\n";	
#		$CDS_feature = "$cds[0][0]\t$cds[0][1]\tCDS\n";
		my $number = $#cds;
		if($number >0){
			$CDS_feature = "$cds[0][0]\t$cds[0][1]\tCDS\n";
			$mRNA_feature = "$cds[0][0]\t$cds[0][1]\tmRNA\n";
			foreach my $i (1..$#cds){
				$CDS_feature .= "$cds[$i][0]\t$cds[$i][1]\n";
				$mRNA_feature .= "$cds[$i][0]\t$cds[$i][1]\n";
			}
		}else{
			$CDS_feature = "$cds[0][0]\t$cds[0][1]\tCDS\n";
			$mRNA_feature = "$cds[0][0]\t$cds[0][1]\tmRNA\n";
		}
			if(exists $swissprot{$gene_p->[1]}){
				$CDS_feature .= "\t\t\tproduct\t$swissprot{$gene_p->[1]}\n";
				$mRNA_feature .= "\t\t\tnote\t$swissprot{$gene_p->[1]}\n";
			}else{
				$CDS_feature .= "\t\t\tproduct\thypothetical protein\n";
				$mRNA_feature .= "\t\t\tnote\thypothetical protein\n";
			}
			$CDS_feature .= "\t\t\tcodon_start\t1\n";
			$CDS_feature .= "\t\t\tprotein_id\tgnl|ncbi|$gene_p->[1]\n";
			$mRNA_feature .= "\t\t\tprotein_id\tgnl|ncbi|$gene_p->[1]\n";
			$CDS_feature .= "\t\t\ttranscript_id\tgnl|ncbi|mrna.$gene_p->[1]\n";
			$mRNA_feature .= "\t\t\ttranscript_id\tgnl|ncbi|mrna.$gene_p->[1]\n";	
			my %swissprot_temp = ();	
			if(exists $Anno{$gene}{Swissprot}) {
				my $Swissprot_p = $Anno{$gene}{Swissprot};
				foreach  (@$Swissprot_p) {
					my $prot_id = $_;
					my $key = $1;
					$swissprot_temp{$key} = 1;
					$CDS_feature .= "\t\t\tdb_xref\tSwiss-Prot:$prot_id\n";
				}
			}

			if(exists $Anno{$gene}{COG}){
				my $COG_p = $Anno{$gene}{COG};
				foreach  (@$COG_p) {
					my $prot_id = $_;
					my $key = $1;
					$CDS_feature .= "\t\t\tdb_xref\tCOG:$prot_id\n";
				}
			}
			if(exists $Anno{$gene}{KEGG}){
				my $KEGG_p = $Anno{$gene}{KEGG};
				foreach  (@$KEGG_p) {
					my $prot_id = $_;
					my $key = $1;
#					$CDS_feature .= "\t\t\tdb_xref\tKEGG:$prot_id\n";
				}			
			}
			if(exists $Anno{$gene}{EC_number}){
                                 my $EC_number_p = $Anno{$gene}{EC_number};
                                 foreach  (@$EC_number_p) {
                                         my $prot_id = $_;
                                         my $key = $1;
                                         $CDS_feature .= "\t\t\tEC_number\t$prot_id\n";
                                 }
                        }
			if(exists $Anno{$gene}{go_component}){
				my $go_component_p = $Anno{$gene}{go_component};
				foreach  (@$go_component_p) {
					my $prot_id = $_;
					my $key = $1;
					$CDS_feature .= "\t\t\tgo_component\t$prot_id\n";
				}
			}
			if(exists $Anno{$gene}{go_process}){
                                 my $go_process_p = $Anno{$gene}{go_process};
                                 foreach  (@$go_process_p) {
                                         my $prot_id = $_;
                                         my $key = $1;
                                         $CDS_feature .= "\t\t\tgo_process\t$prot_id\n";
                                 }
                         }
			if(exists $Anno{$gene}{go_function}){
                                 my $go_function_p = $Anno{$gene}{go_function};
                                 foreach  (@$go_function_p) {
                                         my $prot_id = $_;
                                         my $key = $1;
                                         $CDS_feature .= "\t\t\tgo_function\t$prot_id\n";
                                 }
                         }
			if (exists $Anno{$gene}{TrEMBL}) {
				my $TrEMBL_p = $Anno{$gene}{TrEMBL};
				foreach  (@$TrEMBL_p){
					my $TrEMBL_id =$1 if (/^(\S+)/);
					$CDS_feature .="\t\t\tdb_xref\tTrEMBL:$TrEMBL_id\n";
			    	}
			}

			if (exists $Anno{$gene}{RefSeq}) {
				my $GI_p = $Anno{$gene}{RefSeq};
				foreach  (@$GI_p) {
					my $GI_id = $1 if(/^(\S+)/);
					my $swi= (split /\./,$GI_id)[-2];
					if ( exists $swissprot_temp{$swi} ) {
				    		next;
					}
					if ($GI_id =~/^\S+_\S+/){
						$CDS_feature .= "\t\t\tinference	similar to DNA sequence:RefSeq:$GI_id\n";
					}else{
				    		$CDS_feature .= "\t\t\tinference        similar to DNA sequence:INSD:$GI_id\n";
				 	}
			       	}
			}
			%swissprot_temp = "";
                        $output .= $gene_feture.$mRNA_feature.$CDS_feature;		
			$Locus_mark++;
		}
	open OUT,">$Outdir/$chr.tbl" || die "fail $Outdir/$chr.tbl";
	print OUT $output;
	close OUT;
	print $output unless $output =~ /db_xref/;


}
foreach my $chr (keys %sample){
	my $content = " $tbl2asn -i $Outdir/$chr.fsa -j \"$species\" -V vb -a sr20k -y \"\" -Z discrep -t $template -c b  \n";
	$content .= " sed -i 's/VERSION/VERSION     $chr/g' $Outdir/$chr.gbf \n";
	$content .= " sed -i 's/ACCESSION/ACCESSION   $chr/g' $Outdir/$chr.gbf \n";
	`$content`;
}
####################################################
################### Sub Routines ###################
####################################################

sub number_to_mark {
	my $mark =shift || 100000;
	$mark =~ s/\d/0/g;
	$mark++;
	return $mark;
}

__END__
