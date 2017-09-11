#!/usr/bin/perl -w

die "
perl $0 <seq.fa.list;include nt or other> <list of keyword> <prefix of output>
" if(@ARGV!=3);
my $seqList=shift;
my $list=shift;
my $pre=shift;

my %lists;
open LIST,"$list" or die "$!";
while(my $k=<LIST>){
	chomp $k;
	$lists{$k}="";
}
close LIST;

foreach my $seq(`cat $seqList`){
	chomp $seq;
	my $base=`basename $seq`;
	$base=~ s/\s*$//g;
	print "writing $pre.$base.fa\n";
        open OUT,">$pre.$base.fa" or die "$!";
	open IN,"$seq" or die "$!";
	$/="\n>";
        my $line1=<IN>;chomp $line1;
        my @arr=split(/\n/,$line1,2);
	$arr[0]=~ s/^>//;
	foreach my $k(keys %lists){
                $k=~ s/\|/\\|/g;
		if($arr[0]=~ /$k/i){
			if(!$arr[1]){die "is$. $_\n";}
                        $arr[0]=~ s/[<>]//g;
			print OUT ">$arr[0]\n$arr[1]\n";
			last;
	        }
        }
	
	while(<IN>){
		chomp;
                next if(!$_);
		@arr=split(/\n/,$_,2);
		foreach my $k(keys %lists){
                        $k=~ s/\|/\\|/g;
			if($arr[0]=~ /$k/i){
				if(!$arr[1]){die "is$. $_\n";}
                                $arr[0]=~ s/[<>]//g;
				print OUT ">$arr[0]\n$arr[1]\n";
				last;
			}
		}
	}
	close IN;
	close OUT;
}
