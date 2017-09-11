#!/usr/bin/perl -w
use strict;
use File::Path;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';
use FindBin qw($Bin);
use lib "/ifshk7/BC_PS/yanglin1/Pipeline/Bacteria_Complete_Genome/Bacterial_Genome_Analysis_Pipeline_2016a/lib";
use ToolKit;

#================ Getopt::Long =======================
my ($indir);
GetOptions(
        "indir:s"               =>\$indir,
);
my $usage=<<USAGE;
Description:

        Integration Data Table

Usage: perl $0 [options]
        --indir<str>            Specify Result pathway(Separate).

USAGE
die $usage if (!$indir);
#=======================================================
my (%sample,%cds,%pep,%gff);
die "input Process dir $indir is't exist ~~~~ \n" unless -e $indir;
my $Separate = "$indir/Separate";
$Separate = abs_path $Separate;
die "indir not contain Separate dir" unless -e $Separate;
opendir DIR,"$Separate";
my @file = readdir DIR;
close DIR;
foreach my $file (@file){
	next if $file =~ /^\.$/;
	next if $file =~ /^\.\.$/;
	next if $file =~ /^\./;
	$sample{$file}++;
}
foreach my $sample (sort keys %sample){
	my (%cds,%pep,%gff,%tRNA,%Table,%loucs,%Anno,$Header);
	my $Component = "$Separate/$sample/3.Genome_Component";
	my $Component_header = "Chr\tStart\tEnd\tType\tStand\tID\tDescribe\tSeq\tPep";
	my $Component_header_control = 0;
	if( -e $Component){
		my $gene_cds = "$Component/Gene_Predict/$sample.Gene.cds.fasta";
		my $gene_pep = "$Component/Gene_Predict/$sample.Gene.pep.fasta";
		my $gene_gff = "$Component/Gene_Predict/$sample.Gene.gff";
		if(-e $gene_cds && -e $gene_pep && -e $gene_gff){
			open CDS,"$gene_cds" or die "can't open $sample cds file ~~~\n";
			$/ = ">";<CDS>;
			while(<CDS>){
				chomp;
				my @line = split /\n/,$_;
				my $id = (split /\s+/,$line[0])[0];
				shift @line;
				my $seq = join "",@line;
				$seq =~ s/\s+//g;
				$cds{$id} = $seq;
			}
			close CDS;
			$/ = "\n";

			open PEP,"$gene_pep" or die "can't open $sample pep file ~~~\n";
			$/ = ">";<PEP>;
			while(<PEP>){
			        chomp;
			        my @line = split /\n/,$_;
			        my $id = (split /\s+/,$line[0])[0];
			        shift @line;
			        my $seq = join "",@line;
			        $seq =~ s/\s+//g;
			        $pep{$id} = $seq;
			}
			close PEP;
			$/ = "\n";
			
			open GFF,"$gene_gff" or die "can't open $sample gff file ~~~\n";
			while(<GFF>){
				chomp;
				next if /^#/;
				my @line = split /\t/,$_;
				if($line[2] =~ /gene/){
					if($line[8] =~ /ID=([^;]+);/){
						$Table{Gene}{"$line[0]\t$line[3]\t$line[4]"}= "$line[0]\t$line[3]\t$line[4]\tGene\t$line[6]\t$1\tNA\t$cds{$1}\t$pep{$1}";
						$Component_header_control = 1;
						$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
					}elsif($line[8] =~ /Parent=([^;]+);/){
						$Table{Gene}{"$line[0]\t$line[3]\t$line[4]"}= "$line[0]\t$line[3]\t$line[4]\tGene\t$line[6]\t$1\tNA\t$cds{$1}\t$pep{$1}";
						$Component_header_control = 1;
						$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
					}
				}elsif($line[2] =~ /mRNA/){
					if($line[8] =~ /ID=([^;]+);/){
						$Table{Gene}{"$line[0]\t$line[3]\t$line[4]"}= "$line[0]\t$line[3]\t$line[4]\tGene\t$line[6]\t$1\tNA\t$cds{$1}\t$pep{$1}";
						$Component_header_control = 1;
						$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
					}elsif($line[8] =~ /Parent=([^;]+);/){
						$Table{Gene}{"$line[0]\t$line[3]\t$line[4]"}= "$line[0]\t$line[3]\t$line[4]\tGene\t$line[6]\t$1\tNA\t$cds{$1}\t$pep{$1}";
						$Component_header_control = 1;
						$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
					}	
				}
			}		
		}
		my $tRNA = "$Component/ncRNA_finding/$sample.tRNA.gff";
		if(-e $tRNA){
			open TRNA,"$tRNA" or die "can't open $sample tRNA file ~~~\n";
			while(<TRNA>){
				chomp;
				next if /^#/;
				my @line = split /\t/,$_;
				my $id = $1 if $line[8] =~ /ID=([^;]+);/;
				my $Type = $1 if $line[8] =~ /(Type=[^;]+);/;
				my $Anti_codon = $1 if $line[8] =~ /(Anti-codon=[^;]+);/; 
				$Table{tRNA}{"$line[0]\t$line[3]\t$line[4]"} = "$line[0]\t$line[3]\t$line[4]\ttRNA\t$line[6]\t$id\t$Type;$Anti_codon\tNA\tNA";
				$Component_header_control = 1;
				$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
			}
			close TRNA;
		}
		my $rRNA_fa = "$Component/ncRNA_finding/$sample.denovo.rRNA.fasta";
		if(-e $rRNA_fa){
			open RRNA,"$rRNA_fa" or die "can't open $sample rRNA fa file ~~~ \n";
			$/= ">";<RRNA>;
			while(<RRNA>){
				chomp;
				my @line = split /\n/,$_;
				my ($chr,$start,$end,$stand,$Describe) = ($1,$2,$3,$4,$5) if $line[0] =~ /rRNA_([^_]+_\d+)_(\d+)-(\d+)_DIR([-\+])\s+\/molecule=(\S+)\s+/;				
				my $id = (split /\s+/,$line[0])[0];
				shift @line;
				my $seq = join "",@line;
				$seq =~ s/\s+//g;
				$Table{rRNA}{"$chr\t$start\t$end"} = "$chr\t$start\t$end\trRNA\t$stand\t$id\t$Describe\t$seq\tNA";
				$Component_header_control = 1;
				$loucs{$chr}{$start}= "$chr\t$start\t$end";
			}
			close RRNA;
			$/ = "\n";
		}
		my $miRNA = "$Component/ncRNA_finding/$sample.miRNA.cmsearch.confident.nr.gff";
		if(-e $miRNA){
			open MIRNA,"$miRNA" or die "can't open $sample miRNA gff file ~~~\n";
			while(<MIRNA>){
				chomp;
				next if /^#/;
				my @line = split /\t/,$_;
				my $id = $1 if $line[8] =~ /ID=([^;]+);/;
				$Table{miRNA}{"$line[0]\t$line[3]\t$line[4]"} = "$line[0]\t$line[3]\t$line[4]\tmiRNA\t$line[6]\t$id\t$line[8]\tNA\tNA";
				$Component_header_control = 1;
				$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
			}
			close MIRNA;
		}
		my $snRNA = "$Component/ncRNA_finding/$sample.snRNA.cmsearch.confident.nr.gff";
		if(-e $snRNA){
			open SNRNA,"$snRNA" or die "can't open $sample snRNA gff file ~~~\n";
			while(<SNRNA>){
				chomp;
				next if /^#/;
				my @line = split /\t/,$_;
				my $id = $1 if $line[8] =~ /ID=([^;]+);/;
				$Table{snRNA}{"$line[0]\t$line[3]\t$line[4]"} = "$line[0]\t$line[3]\t$line[4]\tsnRNA\t$line[6]\t$id\t$line[8]\tNA\tNA";
				$Component_header_control = 1;
				$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
			}
			close SNRNA;
		}
		my $sRNA = "$Component/ncRNA_finding/$sample.sRNA.cmsearch.confident.nr.gff";
		if(-e $sRNA){
			open SRNA,"$sRNA" or die "can't open $sample sRNA gff file ~~~\n";
			while(<SRNA>){
				chomp;
				next if /^#/;
				my @line = split /\t/,$_;
				my $id = $1 if $line[8] =~ /ID=([^;]+);/;
				$Table{sRNA}{"$line[0]\t$line[3]\t$line[4]"} = "$line[0]\t$line[3]\t$line[4]\tsRNA\t$line[6]\t$id\t$line[8]\tNA\tNA";
				$Component_header_control = 1;
				$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
			}
			close SRNA;
		}
		my $denovo = "$Component/Repeat_finding/$sample.denovo.out.gff";
		if(-e $denovo){
			open Denovo,"$denovo" or die "can't open $sample Repeat denovo gff file ~~~\n";
			while(<Denovo>){
				chomp;
				next if /^#/;
				my @line = split /\t/,$_;
				my $id = $1 if $line[8] =~ /ID=([^;]+);/;
				$Table{RepeatDenovo}{"$line[0]\t$line[3]\t$line[4]"} = "$line[0]\t$line[3]\t$line[4]\tRepeat:RepeatMasker:Transposon\t$line[6]\t$id\t$line[8]\tNA\tNA";	
				$Component_header_control = 1;
				$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
			}
			close Denovo;
		}
		my $Proteinmask = "$Component/Repeat_finding/$sample.Proteinmask.annot.gff";
		if(-e $Proteinmask){
			open Proteinmask,"$Proteinmask" or die "can't open $sample Repeat Proteinmask gff file ~~~\n";
			while(<Proteinmask>){
				chomp;
				next if /^#/;
				my @line = split /\t/,$_;
				my $id = $1 if $line[8] =~ /ID=([^;]+);/;
				$Table{RepeatProteinmask}{"$line[0]\t$line[3]\t$line[4]"} = "$line[0]\t$line[3]\t$line[4]\tRepeat:Proteinmask:TEprotein\t$line[6]\t$id\t$line[8]\tNA\tNA";
				$Component_header_control = 1;
				$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
			}
			close Proteinmask;
		}
		my $RepeatMasker = "$Component/Repeat_finding/$sample.RepeatMasker.out.gff";
		if (-e $RepeatMasker){
			open RepeatMasker,"$RepeatMasker" or die "can't open $sample Repeat RepeatMasker gff file~~~\n";
			while(<RepeatMasker>){
				chomp;
				next if /^#/;
				my @line = split /\t/,$_;
				my $id = $1 if $line[8] =~ /ID=([^;]+);/;
				$Table{RepeatMasker}{"$line[0]\t$line[3]\t$line[4]"} = "$line[0]\t$line[3]\t$line[4]\tRepeat:RepeatMasker:Transposon\t$line[6]\t$id\t$line[8]\tNA\tNA";
				$Component_header_control = 1;
				$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
			}
			close RepeatMasker;
		}
		my $trf = "$Component/Repeat_finding/$sample.trf.dat.gff";
		if(-e $trf){
			open TRF,"$trf" or die "can't open $sample Repeat trf gff file ~~~\n";
			while(<TRF>){
				chomp;
				next if /^#/;
				my @line = split /\t/,$_;
				my $id = $1 if $line[8] =~ /ID=([^;]+);/;
				my $seq = $1 if $line[8] =~ /Consensus=([^;]+);/;
				$Table{RepeatTRF}{"$line[0]\t$line[3]\t$line[4]"} = "$line[0]\t$line[3]\t$line[4]\tRepeat:TRF:TandemRepeat\t$line[6]\t$id\t$line[8]\t$seq\tNA";
				$Component_header_control = 1;
				$loucs{$line[0]}{$line[3]}= "$line[0]\t$line[3]\t$line[4]";
			}
			close TRF;
		}
		my $CRISPR = "$Component/CRISPR/$sample.CRISPR.stat.xls";
		if(-e $CRISPR){
			open CRISPR,"$CRISPR" or die "Can't open $sample CRISPR stat file~~~\n";
			while(<CRISPR>){
				chomp;
				next if /Sample/;
				my @line = split /\t/,$_;
				$line[5] =~ s/,//g;
				$line[6] =~ s/,//g;
				$Table{CRISPR}{"$line[1]\t$line[5]\t$line[6]"} = "$line[1]\t$line[5]\t$line[6]\tCRISPR\t+\tCRISPR:$line[3]\t$line[4]\t$line[8]\tNA";
				$Component_header_control = 1;
				$loucs{$line[1]}{$line[5]}= "$line[1]\t$line[5]\t$line[6]";
			}
			close CRISPR;
		}
		my $Prophage = "$Component/Prophage/$sample.Prophage.stat.xls";
		if(-e $Prophage){
			open Prophage,"$Prophage" or die "can't open $sample Prophage stat file ~~~\n";
			while(<Prophage>){
				chomp;
				next if /Sample/;
				my @line = split /\t/,$_;
				$line[5] =~ s/,//g;
				$line[6] =~ s/,//g;
				$Table{Prophage}{"$line[1]\t$line[5]\t$line[6]"} = "$line[1]\t$line[5]\t$line[6]\tProphage\t+\tProphage:$line[2]\t$line[4]\tNA\tNA";
				$Component_header_control = 1;
				$loucs{$line[1]}{$line[5]}= "$line[1]\t$line[5]\t$line[6]";
			}
			close Prophage;
		}
#		if(-e )
	}
	my $Function = "$Separate/$sample/4.Genome_Function/";
	if(-e $Function){
		my $Function_stat = "$Function/$sample.annotation.table.xls";
		if (-e $Function_stat){
			open Anno,"$Function_stat" or die "can't open $sample anno stat file ~~~\n";
			while(<Anno>){
				chomp;
				my @line = split /\t/,$_;
				if ($line[0] =~ /Gene_id/){
					shift @line;
					$Anno{Header} = join "\t",@line;
				}else{
					my $id = shift @line;
					$Anno{$id} = join "\t",@line;
				}
			}
		}else{
			print "Can't find $sample Function stat file ~~~\n";
		}
	}
	my $content;
	my $header = "";
	my $str;
	my @temp;
	$header = $Component_header if $Component_header_control == 1;
	$header = "$header\t$Anno{Header}\n" if $Anno{Header};
	next unless %loucs;
	open OUT,">$Separate/$sample/$sample.IntegrationTable.lxs" or die "can't write $sample Integration Data Table file ~~~\n";
	foreach my $chr (sort keys %loucs){
		foreach my $start (sort {$a<=>$b} keys %{$loucs{$chr}}){
			my $id = $loucs{$chr}{$start};
			if($Anno{Header}){
				my @header = split /\t/,$Anno{Header};
				my $number = @header;
				if ($Table{Gene}{$id}){
					@temp = split /\t/,$Table{Gene}{$id};
					if(!$Anno{$temp[5]}){$Anno{$temp[5]}="null"}
					
					$content .= "$Table{Gene}{$id}\t$Anno{$temp[5]}\n";
					print "@temp\n" unless $Anno{$temp[5]};
				}
				$str = &AddNA("$Table{tRNA}{$id}",$number),$content .= "$str\n" if $Table{tRNA}{$id};
				$str = &AddNA("$Table{rRNA}{$id}",$number),$content .= "$str\n" if $Table{rRNA}{$id};
				$str = &AddNA("$Table{miRNA}{$id}",$number),$content .= "$str\n" if $Table{miRNA}{$id};
				$str = &AddNA("$Table{snRNA}{$id}",$number),$content .= "$str\n" if $Table{snRNA}{$id};
				$str = &AddNA("$Table{sRNA}{$id}",$number),$content .= "$str\n" if $Table{sRNA}{$id};
				$str = &AddNA("$Table{RepeatDenovo}{$id}",$number),$content .= "$str\n" if $Table{RepeatDenovo}{$id};
				$str = &AddNA("$Table{RepeatMasker}{$id}",$number),$content .= "$str\n" if $Table{RepeatMasker}{$id};
				$str = &AddNA("$Table{RepeatTRF}{$id}",$number),$content .= "$str\n" if $Table{RepeatTRF}{$id};
				$str = &AddNA("$Table{RepeatProteinmask}{$id}",$number),$content .= "$str\n" if $Table{RepeatProteinmask}{$id};
				$str = &AddNA("$Table{CRISPR}{$id}",$number),$content .= "$str\n" if $Table{CRISPR}{$id};
				$str = &AddNA("$Table{Prophage}{$id}",$number),$content .= "$str\n" if $Table{Prophage}{$id};
			}else{
				$content .= "$Table{Gene}{$id}\n" if $Table{Gene}{$id};
				$content .= "$Table{tRNA}{$id}\n" if $Table{tRNA}{$id};
				$content .= "$Table{rRNA}{$id}\n" if $Table{rRNA}{$id};
				$content .= "$Table{miRNA}{$id}\n" if $Table{miRNA}{$id};
				$content .= "$Table{snRNA}{$id}\n" if $Table{snRNA}{$id};
				$content .= "$Table{sRNA}{$id}\n" if $Table{sRNA}{$id};
				$content .= "$Table{RepeatDenovo}{$id}\n" if $Table{RepeatDenovo}{$id};
				$content .= "$Table{RepeatMasker}{$id}\n" if $Table{RepeatMasker}{$id};
				$content .= "$Table{RepeatTRF}{$id}\n" if $Table{RepeatTRF}{$id};
				$content .= "$Table{RepeatProteinmask}{$id}\n" if $Table{RepeatProteinmask}{$id};	
				$content .= "$Table{CRISPR}{$id}\n" if $Table{CRISPR}{$id};
				$content .= "$Table{Prophage}{$id}\n" if $Table{Prophage}{$id};
			}
		}
	}
	print OUT $header;
	print OUT $content;
	close OUT;
}

#=============== Sub code
sub AddNA{
	my ($str,$number) = @_;
	my @line = split /\t/,$str;
	foreach my $i (1..$number){
		push @line,"NA";
	}
	my $new_str = join "\t",@line;
	return $new_str;
}
