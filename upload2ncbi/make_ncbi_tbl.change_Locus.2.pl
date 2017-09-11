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
  --parameter      set parameter yaml file
  --genome         set genome.fa 
  --gene           set gene gff file after filter
  --annotation     set the combined annotation file
  --swissprot		set the swissprot_id
  --tRNA           set tRNA gff file after filter
  --rRNA           set rRNA gff file after filter
  --sbt            set upload template file
  --verbose        output running progress information to screen  
  --help           output help information to screen  

=head1 Exmple

  perl make_ncbi_tbl.pl --parameter parameter.yaml --genome alomonas.boliviensis.seq --gene cds.gff.filter -annotation Combine_Annotation --swissprot Swissprot.Name -tRNA tRNA.gff.filter -rRNA rRNA.gff.filter --sbt alomonas.boliviensis.sbt 

=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;
use lib "$Bin/../lib";
use YAML qw(Load Dump);

##get options from command line into variables and set default values
my ($Outdir,$Verbose,$Help,$Parameter_file,$genome_file,$Gene_file,$Annotation_file,$swissprot,$tRNA_file,$rRNA_file,$sbt);
GetOptions(
	"parameter:s"=>\$Parameter_file,
	"genome:s"=>\$genome_file,
	"gene:s"=>\$Gene_file,
	"annotation:s"=>\$Annotation_file,
	"swissprot:s"=>\$swissprot,
	"tRNA:s"=>\$tRNA_file,
	"rRNA:s"=>\$rRNA_file,
	"outdir:s"=>\$Outdir,
	"sbt:s"=>\$sbt,
	"verbose"=>\$Verbose,
	"help"=>\$Help
);
mkdir "output";
$Outdir="output";
die `pod2text $0` if (defined $Help);

my %Gene;
my %Anno;
my $total_gene_number;
my $Out_Gene_Locus;
my $Parameter;

my %swissprot;
open(IN,$swissprot)||die `pod2text $0`;
while(<IN>)
{
	chomp;
	my @cut=split /\t/;
	$swissprot{$cut[0]}=$cut[1];
}
close IN;



##read parameter file
if (defined $Parameter_file) {
	open IN, $Parameter_file || die "fail open $Parameter_file";
	$Parameter = Load( join("", <IN>) );
	close IN;
}

##read genome file
open(IN, $genome_file) || die ("can not open $genome_file\n");
$/=">"; <IN>; $/="\n";
while (<IN>) {
     my $chr = $1 if(/^(\S+)/);
      $/=">";
      my $seq = <IN>;
      chomp $seq;
      $/="\n"; 
      open OUT, ">$Outdir/$chr.fsa" || die "fail creat $Outdir/$chr.fsa";
      print OUT ">$chr"." [organism=".$Parameter->{organism}."] [strain=".$Parameter->{strain}."] [gcode=".$Parameter->{gcode}."]\n", $seq;
      close OUT;
}
close(IN);
##read gene gff file
if (defined $Gene_file) {
	open (IN,$Gene_file) || die ("fail open $Gene_file\n");
	while (<IN>) {
          if (/^#/){next;}
    	    s/^\s+//;
		my @t = split(/\t/);
		my $tname = $t[0];
		 my $qname = $1 if($t[8] =~ /^ID=(\S+?);/ || $t[8] =~ /^Parent=(\S+?);/);
		#$Anno{$qname}{product} = ($product ne "ZZZ") ? $product : "Xxx";
		if ($t[2] eq 'mRNA' ) {
			push @{$Gene{$tname}}, ["gene",$qname,$t[3],$t[4],"mRNA",$t[6]];
			$total_gene_number++;
		}
		if ($t[2] eq 'CDS') {
			push @{$Anno{$qname}{cds}}, [$t[3],$t[4]];
		}
	}
	close(IN);
}

	
##read gene annotation file
if (defined $Annotation_file) {
	open(IN, $Annotation_file) || die ("can not open $Annotation_file\n");
	$/=">"; <IN>; $/="\n";
	while (<IN>) {
		my $gene = $1 if(/^(\S+)/);
		$/=">";
		my $anno_str = <IN>;
		chomp $anno_str;
		$/="\n";
		
		my @anno = split /\n/, $anno_str;
		foreach  ( @anno ) {
			if (/(\w+):(.+)/) {
				push @{$Anno{$gene}{$1}},$2;
			}
		}
	}
	close(IN);
}


##read tRNA file
if (defined $tRNA_file) {
	open (IN,$tRNA_file) || die ("fail open $tRNA_file\n");
	while (<IN>) {
	 if (/#/){next};	
	    s/^\s+//;
		my @t = split(/\t/);
		my $tname = $t[0];
		my $qname = $1 if($t[8] =~ /^ID=(\S+?);/ || $t[8] =~ /^Parent=(\S+?);/);
		#my $qname = $1 if($t[8] =~ /Type=(\w+);/);
		push @{$Gene{$tname}}, ["tRNA",$qname,$t[3],$t[4],"tRNA",$t[6]];
		$total_gene_number++;
		
	}
	close(IN);
}


##read rRNA file
if (defined $rRNA_file) {
	open (IN,$rRNA_file) || die ("fail open $rRNA_file\n");
	while (<IN>) {
	    if (/#/){next};
		s/^\s+//;
		my @t = split(/\t/);
		my $tname = $t[0];
		my $qname = $1 if($t[8] =~ /^ID=(\S+?);/ || $t[8] =~ /^Parent=(\S+?);/);
	#	my $qname = $1 if($t[8] =~ /Type=(\w+);/);
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
		
		##deal with tRNA
		if ($gene_p->[0] eq "tRNA") {
			my $product = "tRNA-$Anno{$gene}{product}";
			$output .= "$gene_p->[2]\t$gene_p->[3]\ttRNA\n\t\t\tproduct\t$gene_p->[1]\n";
		#	$output .= "$gene_p->[2]\t$gene_p->[3]\ttRNA\n\t\t\tproduct\t$product\n";
			$Locus_mark++;
		}
		
		##deal with rRNA
		if ($gene_p->[0] eq "rRNA") {
			#print Dumper \$gene_p->[1];
       		    my $product = "$1S ribosomal RNA" if($gene_p->[1] =~ /(\d+)/);
			$output .= "$gene_p->[2]\t$gene_p->[3]\trRNA\n\t\t\tproduct\t$gene_p->[1]\n";
			#$output .= "$gene_p->[2]\t$gene_p->[3]\trRNA\n\t\t\tproduct\t$product\n";
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
#		my $start_code = $val{$gene_p->[1]}[0];
#				my $end_code   = $val{$gene_p->[1]}[1];
#				if(exists $val{$gene_p->[1]} and ($start_code eq "ATG" or $start_code eq "GTG" or $start_code eq "TTG") and ($end_code eq "TAA" or $end_code  eq "TAG" or $end_code eq "TGA" ))
				    $gene_feture = "$cds[0][0]\t$cds[-1][1]\tgene\n\t\t\tgene\t$gene_p->[1]\n";	
				    $CDS_feature = "$cds[0][0]\t$cds[0][1]\tCDS\n";
			if(exists $swissprot{$gene_p->[1]})
			{
				$CDS_feature .= "\t\t\tproduct\t$swissprot{$gene_p->[1]}\n";
			}
			else
			{
				$CDS_feature .= "\t\t\tproduct\thypothetical protein\n";
			}
	
			
			$CDS_feature .= "\t\t\tprotein_id\tgnl|$Parameter->{genome_project_id}|$gene_p->[1]\n";
			
			my %swissprot_temp = ();	
			if (exists $Anno{$gene}{Swissprot}) {
				my $Swissprot_p = $Anno{$gene}{Swissprot};
				foreach  (@$Swissprot_p) {
					my $prot_id = $1 if(/^(\S+)/);
					my $key = $1;
					$swissprot_temp{$key} = 1;
					$CDS_feature .= "\t\t\tdb_xref\tUniProtKB/Swiss-Prot:$prot_id\n";
				}
			}
			if (exists $Anno{$gene}{TrEMBL}) {
			    my $TrEMBL_p = $Anno{$gene}{TrEMBL};
			    foreach  (@$TrEMBL_p){
				my $TrEMBL_id =$1 if (/^(\S+)/);
				$CDS_feature .="\t\t\tdb_xref\tUniProtKB/TrEMBL:$TrEMBL_id\n";
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
                        $output .= $gene_feture.$CDS_feature;		
			$Locus_mark++;
		}


	open OUT,">$Outdir/$chr.tbl" || die "fail $Outdir/$chr.tbl";
	print OUT $output;
	close OUT;



}
my $a=$Parameter->{organism};
my $b="\"[".$a."]\"";
my $c=$Parameter->{Comment};
print $c;
`/home/wangsh3/bin/NCBI_upload/tbl2asn.Linux-2.6.18-238.19.1.el5-x86_64  -p $Outdir -j $b -V vb -a sr20k -y "$c" -Z discrep -t $sbt -c b`;
#if ( ! -e "$genome_file.contig" ){
#`/ifs2/BC_MG/GROUP/wangsh3/bin/WGS_uplod/get_agp.pl $genome_file  1>$genome_file.contig 2>$genome_file.agp`;
#}
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
