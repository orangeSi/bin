#!/usr/bin/perl -w

die "perl $0 <draft.genome> <sam.list> <block size:ex 1000000bp> <outdir> <prefix>\n" if (@ARGV!=5);
use File::Path;


my $draft=shift;
my $sam_list=shift;
my $block_size=shift;
my $outdir=shift;
my $prefix=shift;
mkpath $outdir if(! -e $outdir);

$block_size=~ s/[bp]//ig;
my %blocks;
my $index=0;
my $flag=0;
### split the draft.genome to different blocks
open DRA,"$draft" or die "$!";
$/=">";
<DRA>;
my $tmp_handle="OUT$index";
open $tmp_handle,">$outdir/$prefix.OUT$index.sam.fasta" or die "$!";
while(<DRA>){
    chomp;
    my @arr=split(/\n/,$_,2);
    my $length=length $arr[1];
    $flag+=$length;
    $arr[0]=~ /^(\S+)/;
    my $id=$1;
    $blocks{$id}{handle}="OUT$index";
    $blocks{$id}{len}=$length;
    $blocks{$id}{totallen}=$flag;
    $tmp_handle="OUT$index";
    print $tmp_handle ">$id\n$arr[1]\n";

    if($flag>$block_size){
        print "output $outdir/$prefix.OUT$index.sam.fasta\n";
        close $tmp_handle;
        $flag=0;
        $index++;
        $tmp_handle="OUT$index";
        open $tmp_handle,">$outdir/$prefix.OUT$index.sam.fasta" or die "$!";
        }
    

}
$/="\n";
close DRA;
close $tmp_handle;
#### open handles for blocks
foreach my $id(keys %blocks){
#    print "$id,len:$blocks{$id}{len},totallen:$blocks{$id}{totallen},hanle:$blocks{$id}{handle}\n"
    open $blocks{$id}{handle},">$outdir/$prefix.$blocks{$id}{handle}.sam" or die "$!";    
    print "open handle $blocks{$id}{handle}\n";
    }



### split sam file by blocks
open LIST,"$sam_list" or die "$!";
$flag=0;
my $header;
while(<LIST>){
    chomp;
    my $samfile=$_;
    print "process $.th $samfile\n";
    open SAM,"$samfile"  or die "$!";
    while(<SAM>){
        chomp;
        if(!$flag && $_=~ /^@/){$header.="$_\n";next}else{$flag=1}
        my @arr=split(/\t/,$_);
        if(!exists $blocks{$arr[2]}){next}
        my $handle_tmp=$blocks{$arr[2]}{handle};
        if(!exists $blocks{$arr[2]}{handle}{exist}){print $handle_tmp $header;$blocks{$arr[2]}{handle}{exist}=1}
        print $handle_tmp  "$_\n";
    }
    close SAM;


    }
close LIST;

#### close handles for blocks
foreach my $id(keys %blocks){
#    print "$id,len:$blocks{$id}{len},totallen:$blocks{$id}{totallen},hanle:$blocks{$id}{handle}\n"
    close $blocks{$id}{handle};    
    print "close handle $blocks{$id}{handle}\n";
    }
