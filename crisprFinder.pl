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
	#my $browser=LWP::UserAgent->new;
	$browser->agent('Mozilla/5.0');
	die("Usage:perl $0 <input.genome.fa> Max_size of input is 100M\n\nContract:sikaiwei\@genomics.cn\n") unless(@ARGV==1);
	#$browser->agent('Mozilla/5.0');
	open (INPUT,$ARGV[0]) or die "cannot open $ARGV[0]\n";
	print ("already read your input!\n");
	open (LIST,">url_list.txt");
	open (ERROR,">error.txt");

	my $seq_Content="";
	while (my $line=<INPUT>) {
		$seq_Content.=$line;
	};
	
	
	#my $i=1;
	#my $length=@array;
	#foreach my $element (@array) {
	#my $url_title="crispr.i2bc.paris-saclay.fr";
	my $url_title="129.175.104.57";
	my $target_URL="http://$url_title/cgi-bin/crispr/advRunCRISPRFinder.cgi";  
    my $response=$browser->post($target_URL,[
	"MAX_FILE_SIZE" => 100000000,
	"user_id" => "",
	"fname" =>	"",
	"submit" =>	"FindCRISPR",
	"DIRname" => $date,
	"SeqContent" => $seq_Content ,
	]);  
     
	 

    if($response->is_success){  
		print "first done\n";	
		my $html_Source1=$response->content();
#		"http://crispr.i2bc.paris-saclay.fr/cgi-bin/crispr/advSavefiles.cgi?FN=tmp.fasta&DIR=116.6.99.223_Jul_28_2016_08_47_04"
#		"http://crispr.i2bc.paris-saclay.fr/tmp/output/crisprfinder/116.6.99.223_Jul_28_2016_09_08_41/tmp_2/tmp_2_PossibleCrispr_1"
#		"http://crispr.i2bc.paris-saclay.fr/tmp/output/crisprfinder/116.6.99.223_Jul_28_2016_09_08_41/tmp_2/Spacers_1"
#		"http://crispr.i2bc.paris-saclay.fr/tmp/output/crisprfinder/116.6.99.223_Jul_28_2016_09_08_41/tmp_1/tmp_1_Crispr_1"
		my @first_url=$html_Source1=~ /cgi-bin\/crispr\/advSavefiles\.cgi\?FN=tmp\.fasta&DIR=[^']+/g;
		print "tmp1 is http://$url_title/$first_url[0]\n";
		
		my $medium_url="http://$url_title/".$first_url[0];
		my $response2=$browser->get($medium_url);
			if ($response2->is_success()) {
			
				my $html_Source2=$response2->content();
				# print  MEDIUM  $html_Source2;
				print "get in\n";	
				my @url_list=$html_Source2=~ /tmp\/output\/crisprfinder[^>]+Crispr_\d+/g;
				my $i=0;
				if(@url_list==0){die "no crispr ,exit~"}
				foreach (@url_list) {
					$i=$i+1;
					my $url="http://$url_title/".$_;
					$_=~ /\/([^\/]+$)/g;
					print "tmp2 is $url\n";

					# http://crispr.u-psud.fr/tmp/crisprfinder/116.6.21.98_Jan_10_2014_06_37_59/tmp_1/tmp_1_PossibleCrispr_10
					my $response=$browser->mirror( $url, $1);
									if($response->is_success) {
										print "ok!got ".$i."th\n";
									} else {
											print  "no!Download ".$i."th failed!\n";
											print  ERROR "no!Download ".$i."th failed!\n";

									    }
					print LIST $url."\n";
				}
			} else  { print ERROR "second error!\n".$response2->status_line();}
		
		
		
	
	} else {
		print ERROR "first error!\n".$response->status_line();
	}
	
	close INPUT;
	close LIST;
	close ERROR;
	
