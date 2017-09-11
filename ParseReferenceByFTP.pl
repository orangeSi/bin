#!/usr/bin/perl
use strict;
use File::Path;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';
#================ Getopt::Long =======================
my ($fna,$gff,$faa,$type,$prefix);
GetOptions(
        "fna:s"		=>\$fna,
	"gff:s"		=>\$gff,
	"faa:s"		=>\$faa,
	"type:s"	=>\$type,
	"prefix:s"	=>\$prefix,	
);

my $usage =<<USAGE;
Usage: perl $0 [options]
	--fna<file>		genomic fna file by wget from ncbi ftp
	--gff<file>		genomic gff file by wget from ncbi ftp
	--faa<file>		genomic faa file by wget from ncbi ftp
	--type<str>		Get type sequence,type:gene,CDS,rRNA,default=all
	--prefix<str>		output prefix 	
USAGE

die $usage if !$prefix &&  !$gff && !$faa && !$fna;

#========================
$type ||="gene,CDS,rRNA";
open GFF,"$gff" or die "can't open gff file : $gff ~~~~\n";
my ($product,$protein_id,$gbkey,$gene_name,@temp,%gff,%PepID2GeneID,%postion,%seq,%checkGeneName);
while(<GFF>){
	chomp;
	next if /^#/;
	next if /^$/;
	my @line = split /\t/,$_;
	if($line[2] =~ /gene/){
		my ($locus_tag,$temp);
		@temp = split /;/,$line[8];
		foreach my $temp (@temp){
			$temp =~s/^\s+//g;
			$temp =~s/\s+$//g;
			$gene_name = $1 if $temp =~ /ID=gene(.*)/;
			$locus_tag = $1 if $temp =~ /^locus_tag=(.*)/;
			$locus_tag = $1 if $temp =~ /Name=(.*)/;
			$locus_tag = $1 if $temp =~ /gene=(.*)/;
		}
		if(exists($checkGeneName{$locus_tag})){
			$temp = $locus_tag . "_$checkGeneName{$locus_tag}";
		}else{
			$temp = $locus_tag;
		}
		$checkGeneName{$locus_tag}++;
		$gff{$gene_name}{$line[2]} = "$line[0]\tGenbank\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\tName=$temp;locus_tag=$temp;";
	}
	if($line[2] =~ /CDS/){
		@temp = split /;/,$line[8];
		foreach my $temp (@temp){
			$gene_name = $1 if $temp =~ /Parent=gene(.*)/;
			$product = $1 if $temp =~ /product=(.*)/;
			$protein_id = $1 if $temp =~ /protein_id=(.*)/;
		}
		$gff{$gene_name}{$line[2]} = "$line[0]\tGenbank\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\t;product=$product;protein_id=$protein_id;";
	}	
	if($line[2] =~ /tRNA|rRNA|ncRNA/){
		@temp = split /;/,$line[8];
		foreach my $temp (@temp){
			$gene_name = $1 if $temp =~ /Parent=gene(.*)/;
			$product = $1 if $temp =~ /product=(.*)/;
		}
		$gff{$gene_name}{$line[2]} = "$line[0]\tGenbank\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\t;gbkey=$line[2];product=$product;";
	}
}
close GFF;
open New_GFF,">$prefix.gff" or die "can't write new gff ~~~\n";
foreach my $id (sort{$a<=>$b} keys %gff){
	my (@temp_gene,@temp_cds,@temp_rRNA,$gene_name,@temp_ncRNA,@temp_tRNA,$gbkey,$locus_tag,$Name,$product,$protein_id,$info,);
	@temp_gene = split /[\t;]/,$gff{$id}{gene} if exists $gff{$id}{gene};
	@temp_cds = split /[\t;]/,$gff{$id}{CDS} if exists $gff{$id}{CDS};
	@temp_rRNA = split /[\t;]/,$gff{$id}{rRNA} if exists $gff{$id}{rRNA};
	@temp_tRNA = split /[\t;]/,$gff{$id}{tRNA} if exists $gff{$id}{tRNA};
	@temp_ncRNA = split /[\t;]/,$gff{$id}{ncRNA} if exists $gff{$id}{ncRNA};
	foreach my $temp (@temp_gene){
		$info .= "$temp;",$gene_name = $1 if $temp =~ /Name=(.*)/;
		$info .= "$temp;" if $temp =~ /locus_tag=(.*)/;
	}
	foreach my $temp (@temp_cds){
		$info .= "$temp;",$product = $1 if $temp =~ /product=(.*)/;
		$info .= "$temp;",$protein_id = $1 if $temp =~ /protein_id=(.*)/;
	}
	$PepID2GeneID{$protein_id} = "$gene_name locus=$temp_cds[0]:$temp_cds[3]:$temp_cds[4]:$temp_cds[6] $product;protein_id=$protein_id" if exists $gff{$id}{CDS};
	foreach my $temp (@temp_rRNA){
		$info .= "$temp;" if $temp =~ /gbkey=(.*)/;
		$info .= "$temp;" if $temp =~ /product=(.*)/;
	}
	foreach my $temp (@temp_tRNA){
		$info .= "$temp;" if $temp =~ /gbkey=(.*)/;
		$info .= "$temp;" if $temp =~ /product=(.*)/;
	}
	foreach my $temp (@temp_ncRNA){
		$info .= "$temp;" if $temp =~ /gbkey=(.*)/;
		$info .= "$temp;" if $temp =~ /product=(.*)/;
	}
	if(exists $gff{$id}{gene}){
		print New_GFF "$temp_gene[0]\t$temp_gene[1]\t$temp_gene[2]\t$temp_gene[3]\t$temp_gene[4]\t$temp_gene[5]\t$temp_gene[6]\t$temp_gene[7]\t$info\n";
		$postion{$gene_name}{gene} = "$temp_gene[0]\t$temp_gene[3]\t$temp_gene[4]\t$temp_gene[6]\t$info";
	}
	if(exists $gff{$id}{CDS}){
		print New_GFF "$temp_cds[0]\t$temp_cds[1]\t$temp_cds[2]\t$temp_cds[3]\t$temp_cds[4]\t$temp_cds[5]\t$temp_cds[6]\t$temp_cds[7]\t$info","Parent=$gene_name;\n";
$postion{$gene_name}{CDS} = "$temp_cds[0]\t$temp_cds[3]\t$temp_cds[4]\t$temp_cds[6]\t$info";
	}
	if(exists $gff{$id}{rRNA}){
		print New_GFF "$temp_rRNA[0]\t$temp_rRNA[1]\trRNA\t$temp_rRNA[3]\t$temp_rRNA[4]\t$temp_rRNA[5]\t$temp_rRNA[6]\t$temp_rRNA[7]\t$info\n";		
		$postion{$gene_name}{rRNA} = "$temp_rRNA[0]\t$temp_rRNA[3]\t$temp_rRNA[4]\t$temp_rRNA[6]\t$info";
	}
	print New_GFF "$temp_tRNA[0]\t$temp_tRNA[1]\ttRNA\t$temp_tRNA[3]\t$temp_tRNA[4]\t$temp_tRNA[5]\t$temp_tRNA[6]\t$temp_tRNA[7]\t$info\n" if exists $gff{$id}{tRNA};
	print New_GFF "$temp_ncRNA[0]\t$temp_ncRNA[1]\tncRNA\t$temp_ncRNA[3]\t$temp_ncRNA[4]\t$temp_ncRNA[5]\t$temp_ncRNA[6]\t$temp_ncRNA[7]\t$info\n"if exists $gff{$id}{ncRNA};
}
close New_GFF;

open Pep,"$faa" or die "can't open faa file ~~~\n";
open New_Pep,">$prefix.pep" or die "can't write pep file ~~~\n";
$/ = ">";<Pep>;
while(<Pep>){
	chomp;
	my @line = split /\n/,$_;
	my $id = (split /\s+/,$line[0])[0];
	shift @line;
	my $seq =join '',@line;
	$seq =~ s/(.{1,60})/$1\n/g;
	if(exists($PepID2GeneID{$id})){
		$PepID2GeneID{$id} =~ s/>//g;
		print New_Pep ">$PepID2GeneID{$id}\n$seq";
	}else{
		print "Pep id not find gene id :$id ~~~\n";
	}
}
close Pep;
close New_Pep;

open Seq,"$fna" or die "can't open fna file ~~~\n";
open New_seq,">$prefix.seq" or die "can't write new seq file ~~~\n";
$/ = ">";<Seq>;
while(<Seq>){
	chomp;
	my @line = split /\n/,$_;
	my $id = (split /\s+/,$line[0])[0];
	shift @line;
	my $seq =join '',@line;
	$seq{$id} = $seq;
	$seq =~ s/(.{1,60})/$1\n/g;
	print New_seq ">$id\n$seq";
}
close Seq;
close New_seq;

if($type =~ /gene/){
	open New_gene,">$prefix.mRNA" or die "can't write new mRNA file ~~~\n";
	foreach my $gene_name (sort keys %postion){
		my ($ref,$start,$end,$stand,$info) = split /\t/,$postion{$gene_name}{gene};
		my $seq = &GetSeq($ref,$start,$end,$stand);
		$seq =~ s/(.{1,60})/$1\n/g;
		my $id_info = "locus=$ref:$start:$end:$stand";
		$id_info = "$id_info $1" if $info =~ /product=(.*);\S+/;
		$id_info =~ s/>//g;
		print New_gene ">$gene_name $id_info\n$seq";
	}
	close New_gene;
}
if($type =~ /CDS/){
	open New_CDS,">$prefix.cds" or die "can't write new cds file ~~~\n";
	foreach my $cds_name (sort keys %postion){
		if(exists($postion{$cds_name}{CDS})){
		        my ($ref,$start,$end,$stand,$info) = split /\t/,$postion{$cds_name}{CDS};
		        my $seq = &GetSeq($ref,$start,$end,$stand);
		        $seq =~ s/(.{1,60})/$1\n/g;
			my $id_info = "locus=$ref:$start:$end:$stand";
			$id_info = "$id_info $1" if $info =~ /product=(.*);\S+/;
			$id_info =~ s/>//g;
		        print New_CDS ">$cds_name $id_info\n$seq";
		}	
	}
	close New_CDS;
}

if($type =~ /rRNA/){
        open New_rRNA,">$prefix.rRNA" or die "can't write new rRNA file ~~~\n";
        foreach my $rRNA_name (sort keys %postion){
		if(exists($postion{$rRNA_name}{rRNA})){
	                my ($ref,$start,$end,$stand,$info) = split /\t/,$postion{$rRNA_name}{rRNA}; 
	                my $seq = &GetSeq($ref,$start,$end,$stand);
	                $seq =~ s/(.{1,60})/$1\n/g;
			my $id_info = "locus=$ref:$start:$end:$stand";
			$id_info = "$id_info $1" if $info =~ /product=(.*);/;
			$id_info =~ s/>//g;
 	               print New_rRNA ">$rRNA_name $id_info\n$seq";
		}
        }
	close New_rRNA;
}



#=========== sub code
#======== Get seq
sub GetSeq{
	my ($ref,$start,$end,$stand) = @_;
	($start,$end) = ($end,$start) if ($start >$end);
	my $seq = substr($seq{$ref},$start - 1,$end - $start + 1);
	if ($stand eq "-"){
		my @seq = split //,$seq;
		@seq = reverse @seq;
		$seq =join '',@seq;
		$seq =~ tr/ATCG/TAGC/;
	}
	return $seq;
}





