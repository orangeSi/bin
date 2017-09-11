#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;
use Getopt::Long;
my ($input,$div_gb,$fna,$div_fna,$CDS,$PEP,$tRNA,$rRNA,$cds_gff,$tRNA_gff,$rRNA_gff,$outdir,$help);
GetOptions(
"i:s"=>\$input,					#input genbank file
"div_gb"=>\$div_gb,				#div multi seq to single gbk
"div_fna"=>\$div_fna,				#div  multi seq  to single  fasta
"fna:s"=>\$fna,					#one fna output file
"cds:s"=>\$CDS,					#CDS output file
"pep:s"=>\$PEP,					#PEP output file
"tRNA:s"=>\$tRNA,				#tRNA output file
"rRNA:s"=>\$rRNA,				#rRNA output file
"cds_gff:s"=>\$cds_gff,			
"tRNA_gff:s"=>\$tRNA_gff,
"rRNA_gff:s"=>\$rRNA_gff,
"o:s"=>\$outdir,				#output dir default=`pwd`
);
$input || &help();
$div_gb || $div_fna || $fna ||$CDS || $PEP || $tRNA ||$rRNA ||$cds_gff || $tRNA_gff || $rRNA_gff ||&help();
chomp (my $pwd=`pwd`);
$outdir ||= $pwd;
(-s $outdir) || mkdir $outdir,0755 || die $!;
my $In=Bio::SeqIO->new(-file=>$input,-format=>'genbank');
my %seq_hash;								#store all seq information in genbank;
print "Reading seq\n";
while(my $seq_obj=$In->next_seq){   					#read one seq with annotation information
	my $scaf_id=$seq_obj->display_id;
	$seq_hash{$scaf_id}=$seq_obj;
}
############################################################################################
#			div multi seq gbk to gbk
############################################################################################
if (defined $div_gb){				
	while (my ($scaf_id,$seq_obj)=each %seq_hash){
	print "spliting seq for genbank...\n";
	my $Out=Bio::SeqIO->new(-file=>">$outdir/$scaf_id\.gb",-format=>'genbank');
	$Out->write_seq($seq_obj);
	}
}
############################################################################################
#		divscaf_ide multi seq gbk to fasta
############################################################################################
if (defined $div_fna){
	while (my ($scaf_id,$seq_obj)=each %seq_hash){
	print "spliting seq for fasta ...\n";
        my $Out=Bio::SeqIO->new(-file=>">$outdir/$scaf_id\.fna",-format=>'fasta');
        $Out->write_seq($seq_obj);
        }
}
############################################################################################
#		get one fasta file
############################################################################################
if (defined $fna){
	my $Out=Bio::SeqIO->new(-file=>">$outdir/$fna",-format=>'fasta');
	print "output fasta seq";
	for my $seq_obj(values %seq_hash){
	$Out->write_seq($seq_obj);
	}
}
############################################################################################
#			get feature seq and gff
############################################################################################
$CDS || $PEP || $tRNA || $rRNA || $cds_gff || $tRNA_gff ||$rRNA_gff || exit(0);
print "getting annotation features\n";
$CDS && open my $CDS_fd,">$CDS" || die $!;
$PEP && open my $PEP_fd,">$PEP" || die $!;
$tRNA && open my  $tRNA_fd,">$tRNA" || die $!;
$rRNA && open my $rRNA_fd,">$rRNA" || die $!; 
$tRNA_gff && open my $tRNA_gff_fd,">$tRNA_gff" ||die $!;
$rRNA_gff && open my $rRNA_gff_fd,">$rRNA_gff" || die $!;
$cds_gff && open my $cds_gff_fd,">$cds_gff" || die $!;

while(my ($scaf_id,$seq_obj)=each %seq_hash){
#	$CDS || $PEP || $tRNA || $rRNA || $cds_gff || $rRNA_gff||$tRNA_gff && last;
	my @F=$seq_obj->get_SeqFeatures();										#get all annotation element
	if (defined $CDS){
		&anno_out($CDS_fd,"CDS",$scaf_id,\@F);					#output annotation element
	}
	if (defined $PEP){ 
		&anno_out($PEP_fd,"PEP",$scaf_id,\@F);
	}
	if (defined $tRNA){
		&anno_out($tRNA_fd,"tRNA",$scaf_id,\@F);
	}
	if (defined $rRNA){
		&anno_out($rRNA_fd,"rRNA",$scaf_id,\@F);
	}
	if (defined $cds_gff){
		&gff_out("CDS",$scaf_id,\@F,$cds_gff_fd);
	}
	if (defined $rRNA_gff){ 
		&gff_out("rRNA",$scaf_id,\@F,$rRNA_gff_fd);
	}
	if (defined $tRNA_gff) {
		&gff_out("tRNA",$scaf_id,\@F,$tRNA_gff_fd);
	}
}

############################################################################################
#			Sub anno_out
############################################################################################
sub anno_out{
	my ($fd,$feat_type,$scaf_id,$f_array)=@_;					#outfile,anno_type,anno_array
	my $print;
	my $decide;
	if ($feat_type eq "PEP"){$decide="CDS";}
	else{$decide=$feat_type;}
	for my $feat (@{$f_array}){
		$feat->primary_tag eq "$decide" || next;
		my $desc;			# feature description
		my $locus;
		if ($feat->has_tag('locus_tag')){     
			($locus)=$feat->get_tag_values('locus_tag');
		}elsif($feat->has_tag('gene')){
                        ($locus)=$feat->get_tag_values('gene');
                }elsif  ($feat->has_tag('protein_id') ){
                        ($locus)=$feat->get_tag_values('protein_id');
                }elsif($feat->has_tag('note')){
                         ($locus)=$feat->get_tag_values('note');
                }else{
                                        die "please check locus tag for annotation!";
                }
		my $start=$feat->start;
		my $end=$feat->end;
		my $cut_seq_obj=$feat->spliced_seq;						#feature seq object
		my $cut_seq;											#feature seq
		if ($feat_type eq "PEP"){
			if ($feat->has_tag('translation')){($cut_seq)=$feat->get_tag_values('translation');}   #/translation=" "
			else {$cut_seq=$cut_seq_obj->translate->seq;}										#translate seq by start and end
		}else{
			$cut_seq=$cut_seq_obj->seq;
		}
		$cut_seq=~s/(\w{60})/$1\n/g;
		my $strand=$feat->strand;
		$strand=($strand==1)?"+":"-";
		if ($feat->has_tag('product')){($desc)=$feat->get_tag_values('product');}	# /product= ""  can be changed for specific genbank file 
		elsif($feat->has_tag('note')){($desc)=$feat->get_tag_values('note');}		# /note= ""
		else{$desc="NA";}
		$print.=">$locus\t$desc\t$scaf_id\:$start\-$end\:$strand\n$cut_seq\n";
	}
	$print && print $fd "$print";
}
############################################################################################
#		Sub gff_out
############################################################################################
sub gff_out{
	my ($feat_type,$scaf_id,$f_array,$fd)=@_;
	my $print;
	if ($feat_type eq "CDS"){
		my (%gene,%exon,%CDS);
		for my $feat(@{$f_array}){							#record all gene CDS exon 
			if ($feat->primary_tag eq "gene"){					#record all gene
				my $start=$feat->start;
				my $end=$feat->end;
				my $strand=$feat->strand;
				$strand=($strand==1)?"+":"-";
				my $locus_tag;
				if ($feat->has_tag('locus_tag')){
                 			($locus_tag)=$feat->get_tag_values('locus_tag');
                		}elsif($feat->has_tag('gene')){
                        		($locus_tag)=$feat->get_tag_values('gene');
                		}elsif  ($feat->has_tag('protein_id') ){
                        		($locus_tag)=$feat->get_tag_values('protein_id');
                		}elsif($feat->has_tag('note')){
                        		($locus_tag)=$feat->get_tag_values('note');
               	 		}else{
                        		die "please check locus tag for annotation!";
                		}
				$gene{$locus_tag}=[$scaf_id,$start,$end,$strand];
			}
			if ($feat->primary_tag eq "CDS"){					#record all  CDS 
				my $all_loc=$feat->location;
				print $all_loc->to_FTstring(),"\n";
				my @array_loc=$all_loc->each_Location;
				my $locus_tag;
				if ($feat->has_tag('locus_tag')){
				        ($locus_tag)=$feat->get_tag_values('locus_tag');
				}elsif($feat->has_tag('gene')){
				        ($locus_tag)=$feat->get_tag_values('gene');
				}elsif  ($feat->has_tag('protein_id') ){
                                        ($locus_tag)=$feat->get_tag_values('protein_id');
                                }elsif($feat->has_tag('note')){
                                        ($locus_tag)=$feat->get_tag_values('note');
                                }else{
                                        die "please check locus tag for annotation!";
                                }
			
				my $start=$feat->start;
				my $end=$feat->end;
				my $strand=$feat->strand;
				$strand=($strand==1)?"+":"-";
				$CDS{$locus_tag}=[$scaf_id,$start,$end,$strand];
				for my $loc(@array_loc){					#record all exon
					my $exon_start=$loc->start;
					my $exon_end=$loc->end;
					push @{$exon{$locus_tag}},[$scaf_id,$exon_start,$exon_end,$strand];
				}
			}	
		}
		while(my ($locus_tag,$temp)=each %CDS){
			my ($scaf_id,$start,$end,$strand);
			if (defined $gene{$locus_tag}){      #gene and mRNA desc from /gene
				($scaf_id,$start,$end,$strand)=@{$gene{$locus_tag}};     
			}else{				     #gene and mRNA desc from /CDS
				($scaf_id,$start,$end,$strand)=@{$temp};				
			}
			$print.="$scaf_id\tGenBank\tgene\t$start\t$end\t\.\t$strand\t\.\tID=$locus_tag\;Name=$locus_tag\;Parent=$locus_tag\;complete gene\n";
			$print.="$scaf_id\tGenBank\tmRNA\t$start\t$end\t\.\t$strand\t\.\tID=$locus_tag\;Name=$locus_tag\;Parent=$locus_tag\;complete gene\n";
			for my $exon (@{$exon{$locus_tag}}){
				$print.="$exon->[0]\tGenBank\tCDS\t$exon->[1]\t$exon->[2]\t.\t$exon->[3]\t\.\tParent=$locus_tag\;\n";
			}
		}
	$print && print $fd $print;
	}
	else{													#tRNA or rRNA
		for my $feat(@{$f_array}){
			$feat->primary_tag eq "$feat_type" || next;
			my $desc;my $locus;
			if ($feat->has_tag('locus_tag')){($locus)=$feat->get_tag_values('locus_tag');}		#/locus_tag="  "
			elsif ($feat->has_tag('gene')){($locus)=$feat->get_tag_values('gene');}
			else {die "please check locus tag for $feat_type";}
			my $start=$feat->start;
		        my $end=$feat->end;
		        my $strand=$feat->strand;
	        	$strand=($strand==1)?"+":"-";
			if ($feat->has_tag('product')){($desc)=$feat->get_tag_values('product');}
			elsif($feat->has_tag('note')){($desc)=$feat->get_tag_values('note');}  
			else{$desc="NA";}
			$print.="$scaf_id\tGenBank\t$feat_type\t$start\t$end\t\.\t$strand\t\.\tID=$locus\;product=$desc\;\n";
		}
		$print && print $fd "$print";
	}
}

sub help{
print "perl $0 
Options:
	<-i input genbank file>
	[-div_gb]                             	#divide seq  to multi gbk
	[-div_fna]                              #divide seq  to multi fasta
	[-fna output genome fasta]              #get single fasta
	[-cds output cds fasta]                 #CDS output file
	[-pep output pep fasta]                 #PEP output file
	[-tRNA output tRNA fasta]               #tRNA output file
	[-rRNA output rRNA fasta]               #rRNA output file
	[-cds_gff output gff file]              #cds gff output file
	[-tRNA_gff output gff file]             #tRNA gff output file
	[-rRNA_gff output gff file]             #rRNA gff output file

";
exit(0);
} 
