#! /usr/bin/perl 
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

	open (INPUT,$ARGV[0]) || die("You should use it like:\$ perl get_url_content.pl sequenceFileName.txt\nor check whether the sequence is exist!\n");
	use LWP::UserAgent;  
	use strict;
	my $data=localtime(time);
	print $data."\n";
	my $browser=LWP::UserAgent->new;
	# 当这台主机被封的时候使用下面的代理即可。如果下面的ip是Windows，在上面安装ccproxy即可作为代理服务器，并增加账号和修改端口为8080即可。如果下面的ip是Linux，具体代理配置网上有，暂定。。。
#	$browser->proxy(['http', 'ftp'], 'http://172.16.16.91:8080');
#	$browser->timeout(1000);
	#open (INPUT,$ARGV[0]) || die("You should use it like:\$ perl get_url_content.pl sequenceFileName.txt\nor check whether the sequence is exist!\n");
	print ("already read your input!\n");
	`remove medium.html`;
	open (MEDIUM,">medium.html");#medium.html是存储所有抓取的网页的html源代码#
	open (ERROR,">error.txt");
	open (ALLURL,">all_url.txt");
	open (NOTGOT,">not_got_url.txt");
	open LIST,">url" or die "$!";
#把输入的序列文件整个写入一个字符串$strings
	my $strings="";
	while (my $line=<INPUT>) {
		$strings.=$line;
	};
	my @index=();
#把上面的到的字符串分隔为数组，并删除第一个空元素
	my @array=split(/>[^\n]*\n/,$strings);#以>....\n为分隔符 
	splice(@array,0,1);#s删除第一个空元素
	# my @title=$strings=~ />[^\n]*\n/g;
	my @preTitle=$strings=~ />[^\n]*\n/g;
#	print $preTitle[0]."is 1st\n";
#对数组中的每一个元素即一个序列执行post&&抓取&&输出到txt文件过程。
	my $i=1;
	my $length=@array;
	foreach my $element (@array) {
	my $SUSUI_URL="http://www.prodoric.de/vfp/vfp_promoter_start.php";  
    my $response=$browser->post($SUSUI_URL,["seq_source" => 3,
	"gene_name"	=> "",
	"genome_pos1" => "",
	"genome_pos2" => "",
	"userfile"	=> "",
	"sequence" => $element,
	"pwm_data" => "AbrB | Bacillus subtilis (strain 168)#Ada | Escherichia coli (strain K12)#AhrC | Bacillus subtilis (strain 168)#AlgR | Pseudomonas syringae (pathovar tomato, strain DC3000)#AlgU (-10) | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#AlgU (-35) | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#AlgU (N16) | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#AlgU (N17) | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#Anr | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#Anr_Dnr_37 | Pseudomonas aeruginosa#Anr_Dnr | Pseudomonas aeruginosa#Anr_Dnr_40 | Pseudomonas aeruginosa#AraC | Escherichia coli (strain K12)#AraR | Bacillus subtilis (strain 168)#ArcA | Escherichia coli (strain K12)#ArgR | Escherichia coli (strain K12)#ArgR | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#CRE | Bacillus subtilis (strain 168)#CTSR | Bacillus subtilis (strain 168)#CaiF | Escherichia coli (strain K12)#CcpC | Bacillus subtilis (strain 168)#CitT | Bacillus subtilis (strain 168)#CodY | Bacillus subtilis (strain 168)#ComA | Bacillus subtilis (strain 168)#ComK | Bacillus subtilis (strain 168)#CovR | Streptococcus pyogenes (serovar M18 / M18, strain MGAS8232)#CovR | Streptococcus pyogenes (serovar M18 / M18, strain MGAS8232)#CpxR | Escherichia coli (strain K12)#Crp | Escherichia coli (strain K12)#CspA | Escherichia coli (strain K12)#CtsR | Listeria monocytogenes (serovar 1/2a, strain EGD-e)#CynR | Escherichia coli (strain K12)#CysB | Escherichia coli (strain K12)#CytR | Escherichia coli (strain K12)#DegU | Bacillus subtilis (strain 168)#DeoR | Escherichia coli (strain K12)#DinR/LexA | Bacillus subtilis (strain 168)#DnaA | Escherichia coli (strain K12)#Dnr | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#ExsA | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#FadR | Escherichia coli (strain K12)#FhlA | Escherichia coli (strain K12)#Fis | Escherichia coli (strain K12)#FleQ | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#FlhD2C2 | Escherichia coli (strain K12)#FliA | Escherichia coli (strain K12)#Fnr | Bacillus subtilis (strain 168)#Fnr_neu | Bacillus subtilis#Fnr | Escherichia coli (strain K12)#FruR | Escherichia coli (strain K12)#Fur (18mer) | Escherichia coli (strain K12)#Fur (8mer)| Escherichia coli (strain K12)#Fur | Helicobacter pylori (strain ATCC 700392 / 26695)#Fur | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#GalR | Escherichia coli (strain K12)#GalS | Escherichia coli (strain K12)#GcvA | Escherichia coli (strain K12)#GerE | Bacillus subtilis (strain 168)#GlnG | Escherichia coli (strain K12)#GlnR | Bacillus subtilis (strain 168)#GlpR | Escherichia coli (strain K12)#GlpR | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#GltC | Bacillus subtilis (strain 168)#GltR | Bacillus subtilis (strain 168)#GntR | Escherichia coli (strain K12)#H-NS | Escherichia coli (strain K12)#Hpr | Bacillus subtilis (strain 168)#IHF | Escherichia coli (strain K12)#IHF | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#IciA | Escherichia coli (strain K12)#IlvY | Escherichia coli (strain K12)#LacI | Escherichia coli (strain K12)#LasR | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#LevR | Bacillus subtilis (strain 168)#LexA | Escherichia coli (strain K12)#LicT | Bacillus subtilis (strain 168)#Lrp | Escherichia coli (strain K12)#Lrp (SELEX) | Escherichia coli (strain K12)#Lrp + Leu (SELEX) | Escherichia coli (strain K12)#MalI | Escherichia coli (strain K12)#MalT | Escherichia coli (strain K12)#MarR | Escherichia coli (strain K12)#MetJ | Escherichia coli (strain K12)#MetJ (Selex) | Escherichia coli (strain K12)#MetJ (Selex) | Escherichia coli (strain K12)#MetR | Escherichia coli (strain K12)#MexR | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#Mlc | Escherichia coli (strain K12)#Mlc (Selex) | Escherichia coli (strain K12)#MngR (former FarR) | Escherichia coli (strain K12)#MntR | Bacillus subtilis (strain 168)#ModE | Escherichia coli (strain K12)#Mta | Bacillus subtilis (strain 168)#MtrB | Bacillus subtilis (strain 168)#Nac | Escherichia coli (strain K12)#NagC | Escherichia coli (strain K12)#NagC (Selex) | Escherichia coli (strain K12)#NarL | Escherichia coli (strain K12)#NarL | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#NhaR | Escherichia coli (strain K12)#OmpR (C box)| Escherichia coli (strain K12)#OmpR (F box)| Escherichia coli (strain K12)#OmpR | Escherichia coli (strain K12)#OmpR | Helicobacter pylori (strain ATCC 700392 / 26695)#OxyR | Escherichia coli (strain K12)#OxyR | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#OxyR (SELEX) | Escherichia coli (strain K12)#PdhR | Escherichia coli (strain K12)#PhhR | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#PhoP | Escherichia coli (strain K12)#PrfA | Listeria monocytogenes (serovar 1/2a, strain EGD-e)#PucR | Bacillus subtilis (strain 168)#PurR | Escherichia coli (strain K12)#PvdS | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#PyrR | Bacillus subtilis (strain 168)#RcsAB | Escherichia coli (strain K12)#RegR | Bradyrhizobium japonicum (strain USDA 110)#ResD | Bacillus subtilis (strain 168)#Rex | Bacillus subtilis (strain 168)#RhlR | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#RocR | Bacillus subtilis (strain 168)#RofA | Streptococcus pyogenes (serovar M1, strain SF370 / ATCC 700294)#RpoE-SigE | Escherichia coli (strain K12)#RpoE-SigE | Salmonella typhi (strain CT18)#RpoN | Bradyrhizobium japonicum (strain USDA 110)#RpoN | Bradyrhizobium japonicum (strain USDA 110)#RpoN | Escherichia coli (strain K12)#Sig70 (-10) | Escherichia coli#SigB (-10) | Bacillus subtilis (strain 168)#SigB (-35) | Bacillus subtilis (strain 168)#SigB (N12) | Bacillus subtilis (strain 168)#SigB (N13) | Bacillus subtilis (strain 168)#SigB (N14) | Bacillus subtilis (strain 168)#SigB (N15) | Bacillus subtilis (strain 168)#SigD | Bacillus subtilis (strain 168)#SigE (-10) | Bacillus subtilis (strain 168)#SigE (-35) | Bacillus subtilis (strain 168)#SigE (N13) | Bacillus subtilis (strain 168)#SigE (N14) | Bacillus subtilis (strain 168)#SigE (N15) | Bacillus subtilis (strain 168)#SigH (-10) | Bacillus subtilis (strain 168)#SigH (-35) | Bacillus subtilis (strain 168)#SigL | Bacillus subtilis (strain 168)#SigW (-10) | Bacillus subtilis (strain 168)#SigW (-35) | Bacillus subtilis (strain 168)#SigW (N16) | Bacillus subtilis (strain 168)#SigW (N17) | Bacillus subtilis (strain 168)#SigX (-10) | Bacillus subtilis (strain 168)#SigX (-35) | Bacillus subtilis (strain 168)#SigX (N15) | Bacillus subtilis (strain 168)#SinR | Bacillus subtilis (strain 168)#Spo0A | Bacillus subtilis (strain 168)#Spo0A (II) | Bacillus subtilis (strain 168)#SpoIIID | Bacillus subtilis (strain 168)#TnrA | Bacillus subtilis (strain 168)#TreR | Bacillus subtilis (strain 168)#TrpI | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#Vfr | Pseudomonas aeruginosa (strain ATCC 15692 / PAO1)#Xre | Bacillus subtilis (strain 168)#XylR | Bacillus subtilis (strain 168)#YhiX | Escherichia coli (strain K12)#Zur | Bacillus subtilis (strain 168)#",
	"genome" =>	"PLEASE SELECT...",
	"upstream" =>	"500",
	"msens1"	=> "0.8",
	"nop" =>	"1",
	"csens1" =>	"0.9",
	"core1" =>	"5",
	"constraint" =>	"1",
	"max_results" =>	"3",
	"MAX_FILE_SIZE" =>	"100000000"
	]);  
     
    if($response->is_success){  
	#抓取post后网页中body标签中的onload后跳转的网页地址:$finalUrl
		my $htmlSource=$response->content();
		my @arr=$htmlSource=~ /\/tmp\/result\d+\.html/g;
		# onLoad="self.location.href='../tmp/result1386223209.html'";>
		my $finalUrl="http://www.prodoric.de".$arr[0];
		print ALLURL $i.'st '.$finalUrl."\n";
	#抓取上面得到的网址的内容&&输出到medium.html中
		#my $s = new LWP::UserAgent();
		$finalUrl=~ /(result\d+)/;
		my $name=$1;
		print "output is $name.html\n";
		
		`rm $name.html ;
		 wget $finalUrl -w 60 -O $name.html ;
		 while [ ! -s "$name.html" ]
		 do
			sleep 60
			rm $name.html
			wget $finalUrl -w 60 -O $name.html
		 done
		 cat $name.html >>medium.html`;
		 push @index,$i;
                 local $| = 1;#缓存开始输出
                 print "\rgot ".$i." of ".$length;
                 local $| = 0;#缓存结束输出

		
    }else{  
     print ERROR "Bad luck! ${i}th is not got!ID is $preTitle[$i-1]\n";  

    }  
	
	$i+=1;
};
	#print LIST "cat result*html >medium.html";
	`cat nohup.out |grep "Giving up" >>error.txt`;
	close LIST;
	#`sh url.sh`;
	close ALLURL;
	close NOTGOT;
	close MEDIUM || die("cannot close the medium.html!\n");	
	open (MEDIUM, "medium.html") || die ("Could not open the medium.html file"); 
	print "\nread medium.html\n";
	open(FINAL,">final_result.txt");#结果文件输出在这里
	my $j=0;
	while(my $line=<MEDIUM>) {
	if($line=~/^<\/table></) {
		
	#去掉所有空格
		$line=~ s/&nbsp;//g;
	#匹配结果列表前的序列&&写入FINAL
		$line=~/(Promoter.+)PWM/;
		my @arr1=$1=~/>[^<>]+</g;#$1是匹配到的(Promoter.+)即结果列表前的序列
		my $str1="";
		foreach (@arr1) {
				$str1.=$_;
				}																														
		my @arr2 = split(/<>/,$str1);
		my $str2="";
		foreach (@arr2) {
			$str2.=$_;
		}
		$str2=~ s/\d+/\n/g;#把序列中的数字换成\n
		$str2=~ s/<//g;
        $str2=~ s/>//g;
		my $title=$preTitle[$index[$j]-1];
		chop($title);
		print FINAL $title;  #print FINAL (">".$j);
		print FINAL ($str2."\n");# $str2 is sequence.
		
	#按一定格式输出序列后的结果列表
		$line=~ s/Promoter.+PWM/PWM/;#去掉前面的序列
		#@array=$line=~/>[0-9a-zA-Z()-\+]+</g;
		# $string = "abc123def";
    		# $string =~ s/123/456/; # now $string = "abc456def";
	#匹配><内的元素即要抓取的数据。
		my @array1=$line=~/>[^<>]+</g;
		
		my $str="";
		foreach my $element (@array1) {
			$str.=$element;
		}
		
		#print FINAL ($str."\n");
		my @array2 = split(/<>/,$str);
		#print "first is:".@array2[0]."\n";
		$i=0;
		foreach my $ele (@array2) {
									if($i%6==0) {
														$ele=~ s/>//g;
														my $len1=69-length($ele);
													# print "len1 is: ".$len1."\n";
														print FINAL ($ele." " x $len1 );
												} elsif($i%6==5) {	
																	$ele=~ s/<//g;
																	$ele=~ s/>//g;
																	$ele=~ s/\s//g;
																	print FINAL ($ele."\n");	
							
																} else {    #还可以继续改进为抓取每一列的元素为一个数组。这样可以先判断该数组中元素的最长长度，进而可以动态控制$len2=20-length(@array2[$count]);的20！
																			my $len2=20-length($ele);
																			print FINAL ($ele." " x $len2 );
																			
																		}
									$i++;
								}
	$j+=1;
		
		#print MYFILE 2 ($str."\n");
	} 
	#print ("the line no wanted!\n");
	}
	print ("\noutput is final_result.txt,but first check the error.txt in case\n");
	close FINAL || die("can't close the final!\n");	
	$data=localtime(time);
	print $data."\n";
