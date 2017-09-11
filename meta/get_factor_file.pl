#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Path;
use File::Basename qw(dirname basename);
use Cwd;
use FindBin qw($Bin);

sub usage{
	print STDERR "
	get groups and factors information from config of the pipeline.
	produce \$pre.groupsconf.txt and \$pre.tmpfile.txt
	options:

	-in       <str>  relative abundance file, format: TaxoID(GeneID)\\tSample1\\tSample2\\t...
	-conf     <str>  config file of pipeline
	-out      <str>  output dir, default: ./
	-pre      <str>  output prefix, default: the same string with -key
	-key      <str>  key words of analysis name in the config file
	-help            print this usage

	example:
	perl $0 -conf conf.txt -out ./
	\n";
	exit 1;
}

my($Infile, $Conf, $Outdir, $Prefix, $Key, $Help);
GetOptions(
	"in:s"     => \$Infile,
	"conf:s"   => \$Conf,
	"out:s"    => \$Outdir,
	"pre:s"    => \$Prefix,
	"key:s"    => \$Key,
	"help"     => \$Help,
);
&usage if(!$Conf || !$Infile || !$Key || $Help);

$Outdir ||= "./";
mkdir $Outdir unless(-d $Outdir);
$Prefix ||= $Key;



my (%factor_hash, @group_names, %flag);
open IN, "$Conf" or die $!;
while(<IN>){
	chomp;
	next if(/^\s*#/ || /^\s*$/);
	my @items = split /\s*=\s*/;
	next unless(scalar(@items) == 2);
	next unless($items[0] =~ /groupName/);
	
	my @infos = split /_/, $items[0];
	my $info_names = (exists $infos[2])?"$infos[0]\_$infos[2]":$infos[0];
	next unless($Key eq $items[0] || $Key eq $info_names);
	my @groups = split /\s+/, $items[1];
	foreach my $g(@groups){
		my ($group_name, $sample_list) = split /:/, $g;
		$flag{$group_name}++;
		push @group_names, $group_name if($flag{$group_name} == 1); ## store the order of groups
		my @samples = split /,/, $sample_list;
		foreach my $s(@samples){
			$factor_hash{$s} = $group_name;
		}
	}	
}
close IN;

my @sample_names;
open OUT, "> $Outdir/$Prefix.groupsconf.txt" or die $!;
print OUT "#Sample_name\t$Key\n";
######################### Revised by Owen n 2016-06-15 #############################
## Forced the output order consistent with the input order appears in configure file
foreach my $g(@group_names) {
	foreach my $s(keys %factor_hash){
		if($factor_hash{$s} eq $g) {
			push @sample_names, $s;
			print OUT "$s\t$factor_hash{$s}\n";
			delete $factor_hash{$s};
		} else {}
	}
}
##foreach my $s(sort{$a cmp $b} keys %factor_hash){
##	push @sample_names, $s;
##	print OUT "$s\t$factor_hash{$s}\n";
##}
close OUT;
######################### Revised by Owen n 2016-06-15 #############################
my %head_hash;
my $sample_name_list = join "\t", @sample_names;
open IN, "$Infile" or die $!;
chomp(my $head = <IN>);
my @heads = split /\t/, $head;
for(my $i=0; $i<scalar(@heads); $i++){
	$head_hash{$heads[$i]} = $i;
}
open OUT, "> $Outdir/$Prefix.tmpfile.txt" or die $!;
print OUT "ID\t$sample_name_list\n";
while(<IN>){
	chomp;
	next if(/^\s*#/ || /^\s*$/);
	my @items = split /\t/;
	$items[0] =~ s/\s+/_/g;
	my $data_line = "$items[0]";
	foreach my $s(@sample_names){
		my $tmp_data = $items[$head_hash{$s}];
		$data_line .= "\t$tmp_data";
	}
	print OUT "$data_line\n";
}
close IN;
close OUT;
