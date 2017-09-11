#! /usr/bin/perl -w
use strict;

sub usage {
	print STDERR <<USAGE;

Description:

	choose blast out file by min match percentage%. 


Usage:  choose_blast_m8 -i <blast_list_lile> -o <file_for_chosen_blast_results> <options>

			-i  <C>: input list contain blast m8 results
			-o  <C>: output file of chosen results
	options
			-d  <N>: identity threshold.               Default 40
			-m  <N>: match length threshold.           Default 0
			-e  <N>: e_value threshold.                Default 1e-5
			-p  <N>: min match percentage%.            Default 40
			-q  <C>: query file of blast if -p.
			-s  <C>: subject file of blat if -p.
			-h     : output this help message.
USAGE
}

use Getopt::Std;
getopts('i:o:d:m:e:p:q:s:h');
our ($opt_i,$opt_o,$opt_d,$opt_m,$opt_e,$opt_p,$opt_q,$opt_s,$opt_h);

if($opt_h) {usage;exit;}
unless($opt_i && $opt_o) {usage;exit;}
if ($opt_p && !($opt_q && $opt_s)) {usage;exit;}
$opt_p = 40 unless((defined$opt_p));
$opt_d = 40 unless(defined($opt_d));
$opt_e = 1e-5 unless(defined($opt_e));
$opt_m = 0 unless((defined$opt_m));

#---- filt match percentage
my %seq;
get_seq("query",$opt_q);
get_seq("db",$opt_s);

open BLAST,$opt_i or die "$opt_i $!\n";
open OUT,">$opt_o" or die "$opt_o $!\n";
while(<BLAST>){
	chomp;
	my @split = split;
	die "$opt_i: \"$_\" Not 12 columns, please Check Your blast m8 result!\n" if(@split != 12);
	next if (abs($split[6]-$split[7]))*100/$seq{query}{$split[0]}<$opt_p;
	next if (abs($split[8]-$split[9]))*100/$seq{db}{$split[1]}<$opt_p;
	next if ($split[2] < $opt_d || $split[-2] > $opt_e || $split[3] < $opt_m);
	print OUT join "\t",@split, "\n";
}
close BLAST;
close OUT;
#============= sub ===============
sub get_seq {
	my ($tag,$file)=@_;
	open INA,$file;
	while(<INA>){
		chomp;
		my @split=split /[\t\s]+/,$_;
		$split[0]=~s/>//g;
		$/=">";
		my $seq=<INA>;
		$seq=~s/>//g;
		$seq=~s/\n//g;
		$/="\n";
		$seq{$tag}{$split[0]}=length $seq;
	}
	close INA;
}


