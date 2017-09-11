#!/usr/bin/perl -w
die "perl $0 <stat.list:sample stat statpath> <output> <choosed sample:ex:a,b,c or all>\n" if(@ARGV!=3);
my $list=shift;
my $out=shift;
my $choosed=shift;

my @chooses;
if($choosed=~ /,/){
	@chooses=split(/,/,$choosed);
}elsif($choosed eq "all"){
	foreach my $k(`cat $list|awk '{print \$1}'`){
		chomp $k;
		push @chooses,$k;
	}	
}
my %choose;
foreach my $k(@chooses){$choose{$k}="";}

open IN,"$list" or die "$!";
open OUT,">$out" or die "$!";
my ($title,$line,$content);

while(<IN>){
	chomp;
	my ($sample,$type,$stat)=split(/\s+/,$_);
	die "the format of $list shouldbe:sample statpath\n" if ($type ne "stat");
	if(exists $choose{$sample}){
		open STAT,"$stat" or die "$!";
		$title="";
		while(<STAT>){
			chomp;
			next if(!$_);
			if($_=~ /^Sample Name/ or !$line){
				$title.="$_\n";
				$line=$.;
			}else{
				$content.="$_\n";			}
		}
		close STAT;
		$line="";
		#print "tile is \n$title\ncontent is \n$content\n";
		
	}
}
print OUT "$title$content";
close IN;
close OUT;

