#!/use/bin/perl -w 
use strict;
die "[All m7] [Mb][prefix] \n" if @ARGV != 3;
my ($m7,$size,$prefix) = @ARGV;
my ($header,$control,$sub_content,$all_content,$Iteration_hedaer,$Iteration_end,$file_number,@args,$temp1,$Iteration_query_def);
$size  = $size * 1000 * 1000;
$file_number =1;
$control =0;
$temp1 = 1;
my $Iteration_query_ID_number = 1;
open IN,"$m7";
while(<IN>){
	$header .= $_ if /<\?xml version=/;
	$header .= $_ if /<!DOCTYPE BlastOutput/;
	$header .= $_ if /<BlastOutput>/;
	$header .= $_ if /\s*<BlastOutput_program>/;
	$header .= $_ if /\s*<BlastOutput_version>/;
	$header .= $_ if /\s*<BlastOutput_reference>/;
	$header .= $_ if /\s*<BlastOutput_db>/;
	$header .= $_ if /\s*<BlastOutput_query-ID>/;
	$header .= $_,next if /\s*<BlastOutput_query-def>/;
	$header .= $_ if /\s*<BlastOutput_query-len>/;
	$header .= $_ if /\s*<BlastOutput_param>/;
	$header .= $_ if /\s*<Parameters>/;
	$header .= $_ if /\s*<Parameters_matrix>/;
	$header .= $_ if /\s*<Parameters_expect>/;
	$header .= $_ if /\s*<Parameters_gap-open>/;
	$header .= $_ if /\s*<Parameters_gap-extend>/;
	$header .= $_ if /\s*<Parameters_filter>/;
	$header .= $_ if /\s*<\/Parameters>/;
	$header .= $_ if /\s*<\/BlastOutput_param>/;
	$header .= "  $_" if /<BlastOutput_iterations>/;
	$sub_content = "    $_",$control = 1,next if /<Iteration>/;
	if($control == 1 ){
		$sub_content .= $_;
		if($temp1 == 1 && /<Iteration_query-def>(.*)<\/Iteration_query-def>/){
			$temp1 = 0;
			$Iteration_query_def = $1;
			print "$Iteration_query_def\n";
		}
	}
	if (/<\/Iteration>/){
		$sub_content =~ s/<Iteration_query-ID>.*<\/Iteration_query-ID>/<Iteration_query-ID>lcl\|$Iteration_query_ID_number\_0<\/Iteration_query-ID>/g;
		$Iteration_query_ID_number++;
		$all_content .= $sub_content;
		my $length  = length $all_content;
		if($length > $size){
			open OUT,">$prefix.$file_number.xml";
			my $head = $header;
			$head =~ s/<BlastOutput_query-def>.*<\/BlastOutput_query-def>/<BlastOutput_query-def>$Iteration_query_def<\/BlastOutput_query-def>/g;
			print OUT $head;
			$all_content=~ s/\n(\s*)</\n$1    </g;
			print OUT $all_content;
			print OUT "\n  </BlastOutput_iterations>\n";
			print OUT "</BlastOutput>\n";
			close OUT;
			$file_number++;
			$all_content = "";
			$temp1 =1;
			$Iteration_query_ID_number =1;
		}	
	}elsif(/<\/BlastOutput_iterations>/){
			open OUT,">$prefix.$file_number.xml";
			my $head = $header;
			$head =~ s/<BlastOutput_query-def>.*<\/BlastOutput_query-def>/<BlastOutput_query-def>$Iteration_query_def<\/BlastOutput_query-def>/g;
			print OUT $head;
			print OUT $all_content;
			print OUT "\n  </BlastOutput_iterations>\n";
			print OUT "</BlastOutput>\n";
			close OUT;
			$file_number++;
			$all_content = "";
			$temp1 =1;
			$Iteration_query_ID_number =1;
		
		
	}
	
}
