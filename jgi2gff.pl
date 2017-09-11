#!/usr/bin/perl
# jgi2gff.pl ; from gtf2gff.pl
# d.gilbert; 2006 - update 2007 for stop_codon insert to CDS

use strict;

=item input jgi gff

note not same as gtf; stop_codon is contained in last CDS

scaffold_1      JGI     exon    102936  103037  .       +       .       name "estExt_fgenesh1_pg.C_10005"; transcriptId 219910
scaffold_1      JGI     CDS     102936  103037  .       +       0       name "estExt_fgenesh1_pg.C_10005"; proteinId 219910; exonNumber 1
scaffold_1      JGI     start_codon     102936  102938  .       +       0       name "estExt_fgenesh1_pg.C_10005"
scaffold_1      JGI     exon    103597  103794  .       +       .       name "estExt_fgenesh1_pg.C_10005"; transcriptId 219910
scaffold_1      JGI     CDS     103597  103794  .       +       0       name "estExt_fgenesh1_pg.C_10005"; proteinId 219910; exonNumber 2
scaffold_1      JGI     exon    104011  104369  .       +       .       name "estExt_fgenesh1_pg.C_10005"; transcriptId 219910
scaffold_1      JGI     CDS     104011  104331  .       +       0       name "estExt_fgenesh1_pg.C_10005"; proteinId 219910; exonNumber 3
scaffold_1      JGI     stop_codon      104329  104331  .       +       0       name "estExt_fgenesh1_pg.C_10005"

to:
scaffold_1      JGI     gene    59340   60199   .       +       .       ID=fgenesh1_pg.C_scaffold_1000003;trI
D=Dappu1_FM5_93892
scaffold_1      JGI     mRNA    59340   60199   .       +       .       ID=Dappu1_FM5_93892;Parent=fgenesh1_p
g.C_scaffold_1000003
scaffold_1      JGI     exon    59340   59370   .       +       .       Parent=Dappu1_FM5_93892;ni=15
scaffold_1      JGI     CDS     59340   59370   .       +       0       Parent=Dappu1_FM5_93892;ni=16
scaffold_1      JGI     exon    59491   59620   .       +       .       Parent=Dappu1_FM5_93892;ni=17
scaffold_1      JGI     CDS     59491   59620   .       +       1       Parent=Dappu1_FM5_93892;ni=18
scaffold_1      JGI     exon    59944   60199   .       +       .       Parent=Dappu1_FM5_93892;ni=19
scaffold_1      JGI     CDS     59944   60199   .       +       2       Parent=Dappu1_FM5_93892;ni=20


=cut


my $idprefix="JGI_V11_"; # Fixme: option

my $suf=".gff";
my %renameft = (
'5UTR' => 'five_prime_UTR',
'3UTR' => 'three_prime_UTR',
);
my %dropft = (
'start_codon' => 1,'stop_codon' => 1, # these are all subsumed by CDS/UTR ?
);
my %renamea = (
#'gene_id' => 'Parent',
#'name' => 'Name',
'transcriptId' => 'Parent', # to gene
'proteinId' => 'Parent', # to mRNA
'exonNumber' => 'ni',
'transcript_id' => 'Parent',
);
my %dropa = (
#'transcript_id' => 1,
'gene_id' => 1,
'name' => 1, # not for exons; move to gene ID
);

my ($gid,$tid,$lgid,$ltid, $llgid, $xid, $gname, $lgname, @gv);
my ($stopb,$stope,$stopo)=(0,0,0);

die "usage: jgi2gff.pl files.jgi-gff : convert to files.gff version 3\n"
 if(!@ARGV || $ARGV[0] =~ /^\-/);

my ($gidc,$tidc) = (0) x 10;

foreach my $in (@ARGV) { 
  my $out= $in; $out =~ s/.gz$//;
  unless( $out =~ s/\.\w+$/$suf/ && $out ne $in) { $out.= $suf; }
  
  my $ok= ($in =~ /\.gz$/) ? open(IN,"gunzip -c $in|") : open(IN,$in);
  die "open $in" unless($ok);
  rename($out,"$out.old") if(-e $out);
  open(OUT,">$out") or die "write $out";
  
  $xid=0; # exon-id; helpful
  print OUT "##gff-version 3\n";
  while(<IN>){
    if(/^#/ && !/##gff/) { print OUT; next; }
    next unless(/^\w/);
    chomp;
    my @v=split"\t";
    
    my $isrev= ($v[6] eq '-');
    $gidc++ if(($isrev and $v[2] eq 'stop_codon') or (!$isrev and $v[2] eq 'start_codon') ) ;

    ($stopb,$stope,$stopo)= ($v[3],$v[4],$v[6]) if($v[2] eq 'stop_codon');
    next if ($dropft{$v[2]}); # 07apr: need to add stop_codon loc to last CDS ****
    
    $v[2]=$renameft{$v[2]} || $v[2];
    my @at=split( /\s*;\s*/, $v[8]);
    my @an=();
    $tid= $gid= 0; # $gidc; #??
    foreach (@at) {
      my ($k,$v)= split " ",$_,2;
      $v=~ s/"//g;
      if($k eq 'name') {
        $gid= $v;
        if($gid =~ s/[^\w\.-]/_/g){ $gname= $v; } # $k= "Name";
        else { $gname=""; }
        # keep this one, name is dropped; BUT only for gene entry, not exons
        }
      $tid= $v= $idprefix .$v if($k eq 'transcriptId');
      $tid= $v= $idprefix .$v if($k eq 'proteinId'); # not always same?
      $k= $renamea{$k} || $k;
      push(@an, "$k=$v") unless( $dropa{$k});
      }
    $v[8]= join(";",@an);
    if(!$gid and !$tid) { $gid= $tid= $gidc; }
    elsif (!$gid) { $gid= $tid; }    
    
    # print OUT join("\t",@v),"\n"; # save gene models; adjust stop_codon
    printGene($lgid, $ltid, \@gv, $lgname) if($tid ne $ltid) ;
      
    push(@gv, \@v);
    ($lgid,$ltid,$lgname)=($gid,$tid,$gname);
  }
  
  printGene($lgid, $ltid, \@gv, $lgname) ;
  
  close(OUT); close(IN);
}

sub printGene {
  my($gid, $tid, $rgv, $gname)= @_;
  return unless (@gv);
  
  my ($tb,$te)=(0,0);
  my $isrev= ($stopo eq '-' || $stopo < 0);
  foreach my $g (@gv) {

# not for jgi gff
#     if($$g[2] eq 'CDS' && $isrev && $stope == $$g[3]-1) { $$g[3]= $stopb; }
#     elsif($$g[2] eq 'CDS' && !$isrev && $stopb == $$g[4]+1) { $$g[4]= $stope; }
    
#     if($$g[8] !~ m/;ni=/ && ($$g[2] eq 'CDS' || $$g[2] eq 'exon')) {
#       $xid++; $$g[8] =~ s/$/;ni=$xid/ ; 
#       }

    # also need to add gene, mRNA lines ....
    $tb= $$g[3] if($tb > $$g[3] || $te==0);
    $te= $$g[4] if($te < $$g[4]);
    }
    
  my @tr= @{$gv[0]};
  $tr[2]= "mRNA";
  $tr[5]= "."; # score
  $tr[7]= "."; # phase
  $tr[3]= $tb; $tr[4]= $te;
  $tr[8] =~ s/Parent=/Parent=$gid;ID=/;
  $tr[8] =~ s/;ni=\w+//;
  my $tr= join("\t",@tr);
  my $gn="";
  if($gid ne $llgid) {
    $tr[8] =~ s/ID=/trID=/;
    $tr[8] =~ s/Parent=/ID=/;
    $tr[8] =~ s/$/;Name=$gname/ if($gname);
    $tr[2]= "gene";
    $gn= join("\t",@tr);
    }
  $llgid= $gid;
  
  print OUT join("\n", $gn, $tr, map { join("\t",@$_);} @gv),"\n" ;
  @gv=(); ($stopb,$stope,$stopo)=(0,0,0);
}



=item GTF

  ref: http://mblab.wustl.edu/GTF2.html
  ===== GTF  stop_codon is outside of CDS exon, but before UTR ** ======
  
  chr1	UCSC	start_codon	914833	914835	0	+	.	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	CDS	914833	914983	0	+	0	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	CDS	916667	916829	0	+	2	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	CDS	917659	917774	0	+	1	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	CDS	917933	918011	0	+	2	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	CDS	918082	918581	0	+	1	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	CDS	918776	918900	0	+	2	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	CDS	919221	919331	0	+	0	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	CDS	919431	919673	0	+	0	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	stop_codon	919674	919676	0	+	.	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	3UTR	919677	920104	0	+	.	gene_id "NM_152486"; transcript_id "NM_152486.a";
  chr1	UCSC	5UTR	936110	936216	0	+	.	gene_id "NM_198317"; transcript_id "NM_198317.a";
  
  ....
  AB000123    Twinscan     CDS    193817    194022    .    -    2    gene_id "AB000123.1"; transcript_id "AB00123.1.2";
  AB000123    Twinscan     CDS    199645    199752    .    -    2    gene_id "AB000123.1"; transcript_id "AB00123.1.2";
  AB000123    Twinscan     CDS    200369    200508    .    -    1    gene_id "AB000123.1"; transcript_id "AB00123.1.2";
  AB000123    Twinscan     CDS    215991    216028    .    -    0    gene_id "AB000123.1"; transcript_id "AB00123.1.2";
  AB000123    Twinscan     start_codon   216026    216028    .    -    .    gene_id    "AB000123.1"; transcript_id "AB00123.1.2";
  AB000123    Twinscan     stop_codon    193814    193816    .    -    .    gene_id    "AB000123.1"; transcript_id "AB00123.1.2";


=cut


## this isn't helpful; use plain perl
__END__
use strict;
use Bio::Tools::GFF;
use Bio::FeatureIO;
use Getopt::Long;

my ($output,$input,$format,$type,$help,$cutoff,$sourcetag,$comp,
    $gffver,$match,$quiet);
$format = 'gtf'; # by default
$gffver = 3;
# GTF, is also known as GFF v2.5

GetOptions(
           'i|input:s'  => \$input,
           'o|output:s' => \$output,
           'f|format:s' => \$format,
           'v|version:i'=> \$gffver,
           'q|quiet'    => \$quiet,
           'h|help'     => sub{ exec('perldoc',$0); exit(0) },
           );

# if no input is provided STDIN will be used
my $parser  = new Bio::Tools::GFF(-gff_version => 2.5, -file =>  $input);
#my $parser  = new Bio::FeatureIO(-format => $format, -file   => $input);

my $out;
if( defined $output ) {
  $out = new Bio::Tools::GFF(-gff_version => $gffver, -file => ">$output");
  #$out = new Bio::FeatureIO(-format => 'gff', version => $gffver, -file => ">$output");
} else { 
  $out = new Bio::Tools::GFF(-gff_version => $gffver); # STDOUT
  #$out = new Bio::FeatureIO(-format => 'gff', version => $gffver); # STDOUT
}

while( my $result = $parser->next_feature ) {
  $out->write_feature($result);
  }
__END__


set dp=dana
set species=ananassae
set dpid=${dp}_caf051209
set scd=$sc/${dp}3

$gbl/bin/lu_bulk_load_gff.pl -create -java $gbl/lib/java \
-data lucene-dana_caf1annot   \
$scd/*trna*.gff $scd/*nscan*gff.gz  >& log.lu.dana_caf051209

