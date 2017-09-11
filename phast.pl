#!/usr/bin/perl -w
=head1 Name

fetch_url_content.pl

=head1 Description

Input your sequence file,this script help you post sequence data and output the result that web serve responses in final_result.txt.

=head1 Version

Contact: sikaiwei@genomics.cn
Version: 1.0
Date:2013-12-12

=head1 Usage

perl fetch_url_content.pl yourSequenceFile


=head1 Exmple

perl fetch_url_content.pl test.txt

=cut

use LWP::UserAgent;  
use strict;
my $date=localtime(time);
$date=~ s/\s/_/g;
print $date."\n";
my $browser=LWP::UserAgent->new;
#my $browser2=LWP::UserAgent->new;
$browser->agent('Mozilla/5.0');
#$browser2->agent('Mozilla/5.0');
@ARGV == 3 || die("You should write like:perl  phast.pl <your_input_file> <contig or not> <result prefix>\n\n");

open (INPUT,$ARGV[0]) or die "die $!";
print ("already read your input!\n");
open (FIRST,">1.html");
#open (SECOND,">2.html");
open (ERROR1,">error1.txt");
open (ERROR2,">error2.txt");
open (ERROR3,">error3.txt");
open URL,">url.list" or die "die $!";

open OK,">ok" or die "die $!";
open NONE,">noresult" or die "die $!";
my $seq_Content="";
while (my $line=<INPUT>) {
	$seq_Content.=$line; 
};
my @faste_seq_arr=split('>', $seq_Content);#
shift  @faste_seq_arr;
my $target_URL="http://phast.wishartlab.com/cgi-bin/phage.cgi";  
my $i=0;


sub check{
	my ($second,$name,$j)=@_;
	my $flag=1;
	while($flag){
		print FIRST "in check(),second is $second\n";
		my $response=$browser->get($second);
		if($response->is_success) {
			my $source1=$response->content();
			if($source1=~ /No CDS position is detected/){
				$flag=0;
				print NONE "$name\tNo CDS position is detected\n";
				print OK "$name\tNo CDS position is detected\n";
				next;
				
			}elsif($source1=~ /Our server cannot handle this case bec/){
				$flag=0;
				print NONE "$name\tour server cannot handle this case because  No prophage region detected!\n";	
				print OK "$name\tour server cannot handle this case because  No prophage region detected\n";
				next;
			}
			if($source1=~ /cgi-bin\/change_to_html\.cgi\?num=\d+/) {
				my @arr=$source1=~ /cgi-bin\/change_to_html\.cgi\?num=\d+/g;
				my $response=$browser->get("http://phast.wishartlab.com/".$arr[0]);
				if($response->is_success) {
					my $source1=$response->content();
					$source1=~ /Total : (\d+) prophage regions have been identified/; 
					if($1!=0) {
						my @arr=$source1=~ /tmp\/\d+\/summary.txt/g;
						my $final_url="http://phast.wishartlab.com/".$arr[0];
						print FIRST $final_url;
						my $filename="$ARGV[2]_summary_".$j.".txt";
							my $response=$browser->mirror( $final_url, $filename );
						if($response->is_success) {
							print OK "ok!got $j th summary.txt\n";
							$flag=0;
						} else {
							print ERROR1 "no!Download summary_$j\txt failed!\n";
							$flag=0;
						}
					}else{
						print  NONE "The $j th sequence have no rohpage regions! Title is $name\n";
						$flag=0;
					}
				}else{
					$flag=1;
				}
			}else{
				$flag=1;
			}

		}else {
			print ERROR2 "$j response of server failed!";
			$flag=1;
		}

		sleep 20;

	}






}
#my $limit=$ARGV[1];
foreach (@faste_seq_arr) {
	my $title;
	my $response;
	my @sk;
	if(!($ARGV[1]=~ /contig/)){
		@sk=split(/\n/,$_,2);
		$sk[1]=~ s/\s+//g;
		length$sk[1] >= 1500 || next;	
		print "start $i;$sk[0]\n";
		$_=">".$_;
		$_=~ /^>([^\n]+)/;
		$title=$1;
		$response=$browser->post($target_URL,["fasta_seq" => $_ ]); 
	}else{
		$response=$browser->post($target_URL,["fasta_seq" => $seq_Content , "contig" => "on"]);
		print "contig is on\n";
		$title="one_contig";
	}
	$i=$i+1;
        print "start \n";
	if($response->is_success) {  

		my $source1=$response->content();
		print FIRST  $source1;
		$source1=~ /(Results\.cgi\?num=\d+&multi=\d+)/;
		my $first_url="http://phast.wishartlab.com/cgi-bin/$1";
		#my $response2=$browser->get($first_url1[0]);
		#my $source2=$response2->content();
		#my @first_url2=$source2=~ /Results\.cgi\?num=\d+&multi=\d+/g;
#print "firsturl is ".$first_url[0];
		#my $second="http://phast.wishartlab.com/cgi-bin/".$first_url2[0];
		#print "second is ".$second."\n";
#sleep 20;      
		#print "$source1\n\n";
		#last;	
		print "first url is $first_url\n";
		print URL "$first_url\n";
		


		check($first_url,$title,$i);

	} else {
		print ERROR3 "$title : first error!\n",$response->status_line();
	}
	print "$title : anyway,end $i\n";
	if($ARGV[1]=~ /contig/){last}
}



close FIRST;
close ERROR3;
close ERROR1;
close ERROR2;
close OK;
close NONE; 
close URL;
