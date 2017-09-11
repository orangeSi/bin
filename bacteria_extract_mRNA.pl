#! /usr/bin/perl  -w
use strict;

if (@ARGV==0) {
        print "Usage:perl $0 [genome.fa][*gff][out]\n";
        exit;
}
my %hash;
open IN,$ARGV[0] or die;
$/=">";
<IN>;
while(<IN>){
    chomp;
    my @all = split /\n/,$_;
    my $id=$1 if($all[0] =~ /^(\S+)/);
    shift(@all);
    my $seq=join "",@all;
    $seq =~ s/[\n\t\s]//g;
    $hash{$id}=$seq;
}
$/="\n";
close IN;

open IN,$ARGV[1] or die;
open OUT,">$ARGV[2]" or die;
while(<IN>){
    chomp;
    next if(/CDS/);
    my @all = split;
    my $seq = substr($hash{$all[0]},$all[3] - 1,$all[4] - $all[3] + 1);
    if($all[6] eq '-'){
        $seq = reverse($seq);
        $seq =~ tr/ATCG/TAGC/;
    }
    my $id=$1 if($all[8] =~ /ID=(\S+?)\;/);
    print  OUT ">$id\n$seq\n";
}
close IN;
close OUT;

