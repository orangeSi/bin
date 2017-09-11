#!/usr/bin/perl -w

die "
perl $0 
<seq.fa;include nt or other> 
<list of keyword;fetch all cols>
<flag: 1 or 2 (1 mean fetch all cols of keyword,2:mean fetch first col of keyword)>
<prefix of output>

writed by myth
" if(@ARGV!=4);
my $seq=shift;
my $list=shift;
my $flag=shift;
my $pre=shift;

die "flag must be 1 or 2\n" if($flag ne 1 && $flag ne 2);


my %keys;
open LIST,"$list" or die "$!";
while(my $k=<LIST>){
    chomp $k;
    $k=~ s/\s+$//g;
    my $key;
    if($flag == 1){
        $keys{"$k"}="";
    }else{
        $k=~ /^(\S+)/;
        $keys{"$1"}="";
        }

}
close LIST;


open OUT,">$pre.fa" or die "$!";
my %seqs;
my $base=`basename $seq`;
$base=~ s/\s*$//g;
open IN,"$seq" or die "$!";
$/="\n>";
my $line1=<IN>;chomp $line1;
my @arr=split(/\n/,$line1,2);
$arr[0]=~ s/\s+$//g;
$arr[0]=~ s/[<>]//g;
if($flag == 2){
        $arr[0]=~ /^(\S+)/;
        my $id=$1;
        if(exists $keys{"$id"}){
            print OUT ">$arr[0]\n$arr[1]\n";
        }
}else{
        if(exists $keys{"$arr[0]"}){
            print OUT ">$arr[0]\n$arr[1]\n";
        }
}
while(<IN>){
    chomp;
    $_=~ s/\s*$//;
    next if(!$_);
    @arr=split(/\n/,$_,2);
    $arr[0]=~ s/\s+$//g;
    if($flag == 2){
        $arr[0]=~ /^(\S+)/;
        my $id=$1;
        if(exists $keys{"$id"}){
            print OUT ">$arr[0]\n$arr[1]\n";
        }
    }else{
        if(exists $keys{"$arr[0]"}){
            print OUT ">$arr[0]\n$arr[1]\n";
        }
        
    }

}
close IN;
close OUT;

