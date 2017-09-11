#!/usr/bin/perl -w
#use PerlIO::gzip;
use strict;
use Getopt::Long;

my ($fa,$cutoff_len,$sample,$kmer,$outprefix);

GetOptions(
    'fa=s'          => \$fa,
    'cutoff'        => \$cutoff_len,
    'sample=s'      => \$sample,
    'kmer=s'        => \$kmer,
    'outprefix=s'   => \$outprefix,
);

if (!$fa){
	print"usage:perl n50_fa.pl --fa <fasta_seq> --cutoff <seq_cutoff> --sample <samplename> --kmer <kmersize> --outprefix <outfile> ";
	exit;
}

$cutoff_len ||= 0;
$outprefix ||= $fa;
$sample ||= "test_sample";
$kmer ||= "unknown";

if($fa=~/\.gz$/){
#	open IN,"<:gzip",$fa or die;
	open IN, "gzip -dc $fa|" or die $!;
}else{
	open IN, $fa or die $!;
}
sub nx($);

open STAT,">$outprefix.stat" or die $!;
print STAT "cutoff_len: $cutoff_len\n";

my @array_len=();
my $total_len=0;
my %total_len_n=();
my $count=0;
my $len=0;
my $average_len=0; 
my $line="";

while(<IN>){
	chomp;
	if(/^>/){
		$line=$_;
		if($len>$cutoff_len){
			$total_len+=$len;
					if($len>=30000){$total_len_n{30000}++;}	
					elsif($len>=25000){$total_len_n{25000}++;}
					elsif($len>=20000){$total_len_n{20000}++;}
					elsif($len>=15000){$total_len_n{15000}++;}
					elsif($len>=10000){$total_len_n{10000}++;}
					elsif($len>=5000){$total_len_n{5000}++;}
					elsif($len>=3000){$total_len_n{3000}++;}
					elsif($len>=2500){$total_len_n{2500}++;}
					elsif($len>=2000){$total_len_n{2000}++;}
					elsif($len>=1500){$total_len_n{1500}++;}
					elsif($len>=1000){$total_len_n{1000}++;}
					elsif($len>=500){$total_len_n{500}++;}
					elsif($len>=200){$total_len_n{200}++;}
					elsif($len>=0){
						$total_len_n{0}++;
						#print "found",$line,"\n";
						}
					else{
						$total_len_n{"else"}++;
						}
                	push @array_len,$len;
		}
		$len=0;
	}
	else {$len += length;}
}
close IN;

$total_len+=$len;
					if($len>=30000){$total_len_n{30000}++;}
                                        elsif($len>=25000){$total_len_n{25000}++;}
                                        elsif($len>=20000){$total_len_n{20000}++;}
                                        elsif($len>=15000){$total_len_n{15000}++;}
                                        elsif($len>=10000){$total_len_n{10000}++;}
					elsif($len>=5000){$total_len_n{5000}++;}
                                        elsif($len>=3000){$total_len_n{3000}++;}
					elsif($len>=2500){$total_len_n{2500}++;}
					elsif($len>=2000){$total_len_n{2000}++;}
					elsif($len>=1500){$total_len_n{1500}++;}
					elsif($len>=1000){$total_len_n{1000}++;}
					elsif($len>=500){$total_len_n{500}++;}
					elsif($len>=200){$total_len_n{200}++;}
                                        elsif($len>=0){
                                                $total_len_n{0}++;
                                                #print "found",$line,"\n";
                                                }
                                        else{
                                                $total_len_n{"else"}++;
                                                #print "else$line\n";
						}

#if($len>1000){$total_len_1000++;}
#if($len>2000){$total_len_2000++;}
#if($len>10000){$total_len_10k++;}
push @array_len,$len;

$count = @array_len;
@array_len = sort {$b<=>$a} @array_len;
my %n_dist=();
my $nlen=0;
my $n=10;
my $i=0;
while($i<@array_len || $n<100){
	if($nlen*100<$total_len*$n) {
		$nlen += $array_len[$i];
		$i++;
	}
	if($nlen*100>=$total_len*$n){
                $n_dist{$n}->{"length"}=$array_len[$i-1];
                $n_dist{$n}->{"index"}=$i;
                print STAT "N$n\t",$n_dist{$n}->{"length"},"\t",$n_dist{$n}->{"index"},"\n";
                $n+=10;
        }

}

#for(my $n=90;$n>0;$n-=10){
#	my ($nlen,$index) = nx($n);
#	print "N$n\t$nlen\t$index\n";
#}
$average_len=int($total_len/$count);
#print "Max length = $array_len[0]\n";
#print "Total length = $total_len\tTotal number = $count\tAverage length = $average_len\n";
#print "Number>1000bp = $total_len_1000\tNumber>2000bp = $total_len_2000\tNumber>10kbp = $total_len_10k\n\n";
print STAT "\tSample\tkmer\tTotal number\tTotal length\tN50\tN90\tMax\tMin\tAverage\n";
print STAT "Summary\t$sample\t$kmer\t$count\t$total_len\t",$n_dist{50}->{"length"},"\t",$n_dist{90}->{"length"},"\t$array_len[0]\t$array_len[-1]\t$average_len\n";
close STAT;
open (LENGTH, ">$outprefix.length") or die $!;
my $pkey=-2;
my %label;
foreach my $key (sort {$b<=>$a} keys %total_len_n){
	if ($pkey==-2){
		$label{$key}=">=$key";
	}
	else{
		$label{$key}="$key~$pkey";
	}
	$pkey=$key-1;
}
#if ($pkey>0){$label{0}="0~$pkey";total_len_n{0}=0;}
foreach my $key (sort {$a<=>$b} keys %total_len_n){
    print LENGTH "$key\t",$total_len_n{$key},"\t",$label{$key},"\n";
}
close LENGTH;
#sub nx($){
#	my ($n)=@_;
#	my $nlen=0;
#	for (my $i=0;$i<@array_len;$i++ ){
#		$nlen += $array_len[$i];
#		if($nlen*100>=$total_len*$n){
#			return ($array_len[$i],$i+1);
#			last;
#		}
#	}
#}
