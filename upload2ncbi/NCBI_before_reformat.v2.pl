#!/usr/bin/perl -w
=head1 Name

NCBI_before_filter.pl  -- filter annotation file for NCBI submission

=head1 Description

read from a set of files:cds,cds.gff,tRNA.structure,tRNA.gff,denovo.rRNA.fa,rRNA.gff,
                         swissprot.list.anno,trembl.list.anno,nr.list.anno.

=head1 Version

   Author: Wang Shuang, wangshuang3@genomics.org.cn
   Version: 1.0,  Date: 2011-09-30
   Note:You should link these files to your current dir to conduct this program,the file name can't contain path name.I'm sorry for you inconvenient!

=head1 Usage

  perl NCBI_before_filter.pl <options>
  --cds1              set cds file from Glimmer3 (need)
  --cds2              set cds.gff file from Glimmer3 (need)
  --swissprot         set swissprot annotation file from analysis Result (need)
  --trembl            set trembl annotation file from analysis Result (optional)
  --nr                set nr annotation file from analysis Result (optinnal)
  --kegg 	      set kegg annotation file from analysis Result (optinnal)
  --cog		      set cog annotation file from analysis Result (optinnal)	
=head1 Exmple
 
perl NCBI_before_filter.pl 
                           
                           --cds1 Halomonas.boliviensis.glimmer.cds 
                           --cds2 Halomonas.boliviensis.glimmer.gff
                           --tRNA1 Halomonas.boliviensis.tRNA.structure 
			   --tRNA2 Halomonas.boliviensis.tRNA.gff 
			   --rRNA1 Halomonas.boliviensis.rRNA.fa 
			   --rRNA2 Halomonas.boliviensis.rRNA.gff 
			   --swissprot Halomonas.boliviensis.swissprot.list.anno 
			   --trembl Halomonas.boliviensis.trembl.list.anno  
			   --nr  Halomonas.boliviensis.nr.list.anno

=cut

use strict;
use Getopt::Long;
use Data::Dumper;

my($cds,$cds_gff,$tRNA,$trna_gff,$rRNA,$rRNA_gff,$swiss,$trembl,$nr,$cog,$kegg);
GetOptions(
        "cds1:s"=>\$cds,
	"cds2:s"=>\$cds_gff,
	"tRNA1:s"=>\$tRNA,
	"tRNA2:s"=>\$trna_gff,
	"rRNA1:s"=>\$rRNA,
	"rRNA2:s"=>\$rRNA_gff,
	"swissprot:s"=>\$swiss,
        "trembl:s"=>\$trembl,
        "nr:s"=>\$nr,
	"cog:s"=>\$cog,
	"kegg:s"=>\$kegg
	);
open (CDS,$cds) || die `pod2text $0`;
open CDSF,">cds.filter" || die $!;
open ACDSL,">all.cds.list" || die $!;
##filter cds for seq N>45% and stop condon contain N 
my (%cds, %stop,%N,%tR,%rR);
$/=">";
<CDS>;
while(<CDS>)
{
	chomp;
	my($pos,$len,$end,$rate)=(0,0,0,0);
	my($id,$seq)=(split /\s+/,$_,2);
	print ACDSL "$id","\n";
	$seq=~s/[\n\r\s]//g;
	my $stop_codon=substr($seq,-3,3);
	if ($stop_codon=~/N/){
	    $stop{$id}=1;
	}

	while($seq=~/(N{1,})/g){
		$pos=index($seq,$1,$pos+$len+1)+1;	
		$len=length($1);
		$end=$pos+$len-1;
	   	$cds{$id}+=$len;
	}

	if ($seq=~/(N{1,})/g){
	$rate=100*($cds{$id}/length($seq));
         if ($rate>45){
	     $N{$id}=$id;
	 }
	}
           if (defined $N{$id} or $stop{$id}){
	       next;}
	   else{
print CDSF ">",$_;
	   }
}
$/ = "\n";
close CDS;
close CDSF;
close ACDSL;
##pick tRNA seq from tRNA.structure and use tRNA and rRNA blast new  cds to filter the tRNA and rRNA that in  cds
open TRNA,"<$tRNA" || die $!;
open TRAL,">tRNA.all" || die $!;
my ($name,$seq,$new_name_1,$new_name_2,$new_name);
$/="Scaffold";
<TRNA>;
while (<TRNA>){
    chomp;
    my @a=split /\n/;
    if (@a == 5){
     ($name,$seq) = (split /\n/,$_)[0,3];
     ($new_name_1,$new_name_2)=(split /\s+/,$name)[0,1];
     $new_name_2 =~ s/\(//;
     $new_name_2 =~ s/\)//;
     $new_name = join"_",$new_name_1,$new_name_2;
     $seq =~ s/^Seq:\s+//;
    print TRAL ">Scaffold",$new_name,"\n",$seq,"\n";
   }elsif(@a == 6){
      ($name,$seq) = (split /\n/,$_)[0,4];
      ($new_name_1,$new_name_2)=(split /\s+/,$name)[0,1];
      $new_name_2 =~ s/\(//;
      $new_name_2 =~ s/\)//; 
      $new_name = join"_",$new_name_1,$new_name_2;
       $seq =~ s/^Seq:\s+//;
    print TRAL ">Scaffold",$new_name,"\n",$seq,"\n";
   }
    }
$/="\n";
close TRNA;
close TRAL;
system "/opt/blc/genome/biosoft/blast-2.2.26/bin/formatdb -i cds.filter -p F ";
`/opt/blc/genome/biosoft/blast-2.2.26/bin/blastall -i tRNA.all -d cds.filter -p blastn -m 8 -F F -e 1e-5 -o $tRNA.blast.out`;
`/opt/blc/genome/biosoft/blast-2.2.26/bin/blastall -i $rRNA -d cds.filter -p blastn -m 8 -F F -e 1e-5 -o $rRNA.blast.out`;
open TRBL,"<$tRNA.blast.out" or die $! ;
my($scaf,$pos,$new_pos,$new_scaf);
while (<TRBL>){
    chomp;
    my $map_t = (split /\s+/,$_)[0];
    ($scaf,$pos) = (split /\_/,$map_t)[0,1];
    $new_scaf = (split /\./,$scaf,2)[0];
    $new_pos = (split /\-/,$pos,2)[0];
    $tR{$new_scaf}{$new_pos}=1;
}
close TRBL;
open TRGF,"<$trna_gff" or die $! ;
open TRGFT,">tRNA.gff.filter" or die $!;
my(@t_gff);
while (<TRGF>){
   chomp;
   if (/#/){next};
    @t_gff = split /\s+/;
   if ( exists $tR{$t_gff[0]}{$t_gff[3]} || exists $tR{$t_gff[0]}{$t_gff[4]}){
       next;
}else{
    print TRGFT $_,"\n";
  }  
}
close TRGF;
close TRGFT;
open RRBL,"<$rRNA.blast.out" or die $! ;
while (<RRBL>){
    chomp;
    my $map_r = (split /\s+/,$_)[0];
    my ($rrna_sca,$rrna_pos)=(split /\_/,$map_r,4)[1,2];
    my $new_rrna_pos = (split /\-/,$rrna_pos,2)[0];
    $rR{$rrna_sca}{$new_rrna_pos}=1;
}
open RRGF,"<$rRNA_gff" or die $!;
open RRGFT,">rRNA.gff.filter" or die $!;
while (<RRGF>){
    chomp;
    if (/#/){next};
    my @r_gff =split /\s+/;
    if (exists $rR{$r_gff[0]}{$r_gff[3]} ||  exists $rR{$r_gff[0]}{$r_gff[4]}){
	next;
    }else{
	print RRGFT $_,"\n";
    }
}
 close RRGF;
 close RRGFT;
##print final cds.gff.filter
open CGF,"<$cds_gff" || die $!;
open CGFF,">cds.gff.filter" ||die $!;
while (<CGF>){
    chomp;
    next if ($_ =~/^#/ || $_ eq "");
    my $id_name = (split /\s+/,$_)[8];
    my $id_new1 = (split /;/,$id_name)[0];
    my $id_new = (split /=/,$id_new1)[1];
    if ((exists $N{$id_new}) ||  (exists $stop{$id_new})){ next;}
    else{
	print CGFF "$_\n" ;
 }
}
`rm cds.filter.n* formatdb.log tRNA.all cds.filter $rRNA.blast.out $tRNA.blast.out`;
close CGF;
close CGFF;
#change swissprot name format and combine annotation 
open SWI,"<$swiss" ||die $!;
open SWINAME,">Swissprot.Name"||die $! ;
open SWIANO,">swissprot.list.anno.out" || die $!;
while (<SWI>){
  chomp;
  if ($_=~/^Gene_id/){next};
  my ($gene,$gene_id,$anno)=(split /\s+/,$_,6)[0,3,5];
  #print $anno;
  my $product =(split /OS/,$anno,2)[0];
  #print $product,"\n";
  $product=~s/\s+$//;
  $product=~s/\S+\-like$/\-like protein/;
  $product=~s/[-| ]homolog/\-like protein/;
  $product=~s/\w+\_[\w+]\d{3,}//;
  $product=~s/gene|genes//;
  $product=~s/s$//;
  $product=~s/(\S+\d{3,}\/){1,}$//;
  $product=~s/^Probable/putative/;
  $product=~s/\'$//;
  $product=~s/(Fragment)//;
  $product=~s/\[\S+\]//;
  if ($product=~/^UPF/ or $product=~/^DUF/ or /^IS/){
      my @array=split /\s+/,$product;
      my $database= shift @array;
      $product=join " ",@array;
      $product=~s/\d{3,}//;
      $product=$database." ".$product;
  }else{
       $product=~s/\w+\d{3,}$//;
       $product=~s/\S*\d{3,}\S*//;
       $product=~s/(\S+\d{3,}\/){1,}$//;
  }
  if ($product=~/protein\s+\w+\d{3,}/,$product=~/[U|u]ncharacterized|[U|u]ncharacterized protein/ or $product=~/[m|M]itochondrial/ or $product=~/chloroplastic/ or $product=~/[B|b]ifunctional/ or $product=~/Multifunctional/){
      $product="hypothetical protein";
  }
  print SWINAME $gene,"\t",$product,"\n";
  #print $product,"\n";
  print SWIANO $gene,"\t","Swissprot:",$gene_id,"\n";
}
if (defined $trembl){
open TRE,"<$trembl" || die $!;
open TREANO,">trembl.list.filter.anno.out" ||die $!;
while (<TRE>){
     chomp;
     my ($gene,$gene_id,$anno)=(split /\s+/,$_,6)[0,3,5];
     my $product =(split /OS/,$anno,2)[0];
     print TREANO $gene,"\t","TrEMBL:",$gene_id,"\n";
   }
close TRE;
close TREANO;
}
if (defined $nr){
    open NR,"<$nr" ||die $!;
open NRANO,">nr.list.filter.anno.out" || die $!;
while (<NR>){
        chomp;
         my ($gene,$ref)=(split /\t/,$_,5)[0,3];
	 my $temp = $1 if ($ref =~ /gi\|\d+\|\w+\|(\S+)\|/);
         print  NRANO $gene,"\t","RefSeq:",$temp,"\n";
 }
close NR;
close NRANO;
}

if(defined $kegg){
   open KEGG, "<$kegg" || die "$!\n";
   open KEGGANO, ">kegg.list.filter.anno.out" ||  die "$!\n";
   while(<KEGG>){
   chomp;
   next if($_ eq "" || $_ =~  /^geneID/);
   my ($gene,$kegg_ID,$ko_defi,$ko_EC) = (split /\t/,$_)[0,3,6,7];
   if($ko_EC =~ /--/){
   print KEGGANO "$gene\tKEGG:$kegg_ID $ko_defi\n";
   }else{
   print KEGGANO "$gene\tKEGG:$kegg_ID $ko_defi;$ko_EC\n";
   }		 
   }   
   close KEGG;
   close KEGGANO;
}

if(defined $cog){
    open COG,"<$cog" || die "$!\n";
    open COGANO, ">cog.list.filter.anno.out" || die "$!\n";
    while(<COG>){
	chomp;
	next if($_ eq "");
	 my($gene,$gene_id)=(split /\s+/,$_)[0,4];
	  print COGANO "$gene\tCOGs:protein motif:COGs:$gene_id\n";
    }
    close COG;
    close COGANO;
}

`cat *.anno.out >anno.all`;
`rm *.anno.out`;
close SWI ;
close SWINAME;
close SWIANO;
#filter anno to combine.anno
open ACDS,"<all.cds.list" or die;
open AAOT,"<anno.all" or die;
open CANO,">Combine_Annotation" or die;
my %hash;
while (<ACDS>){
    chomp;
    s/^>//;
    $hash{$_}{id}=1;
}
while (<AAOT>){
    chomp;
    my @a=split /\t/;
    push @{$hash{$a[0]}{array}},$a[1];
}
foreach my$gene_id ( sort keys %hash ){
    if  (!defined $hash{$gene_id}{array}){
	next;
    }
    else{
	print CANO ">",$gene_id,"\n";
        foreach my $annotation ( @{$hash{$gene_id}{array}} ){
          print CANO $annotation,"\n";
	}
    }
}
`rm all.cds.list anno.all`;
close ACDS;
close AAOT;
close CANO;
