#!/usr/bin/perl -w
#
#Author: Ruan Jue <ruanjue@genomics.org.cn>
#
use warnings;
use strict;

die "Usage: perl $0 <scaf.fa> <minlen> > <outfile>" if(@ARGV < 1);

my $infile = $ARGV[0];
my $min_length = 1000;
$min_length = $ARGV[1] if(@ARGV == 2);
my $name = '';
my $seq = '';

if($infile=~/\.gz$/){
        open IN, "gzip -dc $infile|" or die $!
}else{
	open IN, $infile or die $!;
}
                       
while(<IN>){
   if(/^>(\S+)/){
      &print_scafftig($name, $seq) if($seq);
      $name = $1;
      $seq  = '';
   } else {
      chomp;
      $seq .= $_;
   }
}
close IN;
&print_scafftig($name, $seq) if($seq);

1;

sub print_scafftig {
   my $name = shift;
   my $seq  = shift;
   my $temp = $seq;
   my $id = 1;
   my $flag = 0;
   my $pos = 1;
   while($seq=~/([ATGCatgc]+)/g){
   my $s = $1;
   if($flag==1){
      if($temp=~/([ATGCatgc]+[Nn]+)/g){
         my $g = $1;
         $pos+=length($g);
      }
   }
   else{$flag=1;}
   next if(length($s) < $min_length);
   print ">$name\_$id  start=$pos  length=".length($s)."\n";
   while($s=~/(.{1,60})/g){
      print "$1\n";
   }
   $id++;
}
}
