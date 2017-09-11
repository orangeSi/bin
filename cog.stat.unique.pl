#!/usr/bin/perl -w

my %cog;
my %cogname;
open IN,"MN0471.cog.list.anno.xls" or die "";
<IN>;
while(<IN>){
	my @arr=split(/\t/,$_);
	$_=~ /(\S+)\t([^\t]+)$/ ;
	my ($class,$funciton)=($1,$2);
	if(length $class >1){
		my @arr_class=split(//,$class);
		my @arr_fun=split(/;/,$funciton);
		for(my $i=0;$i<1;$i++){
			
			$cog{$arr_class[$i]}{"geneid"}{'chr'}{$arr[0]}="";
			$cogname{$arr_class[$i]}=$arr_fun[$i];

		}

	}else{
		$cog{$class}{"geneid"}{'chr'}{$arr[0]}="";
		$cogname{$class}=$funciton;
	}

}
close IN;

open IN,"plasmid1.cog.list.anno.xls" or die "";
<IN>;
while(<IN>){
	my @arr=split(/\t/,$_);
	$_=~ /(\S+)\t([^\t]+)$/ ;
	my ($class,$funciton)=($1,$2);
	if(length $class >1){
		my @arr_class=split(//,$class);
		my @arr_fun=split(/;/,$funciton);
		for(my $i=0;$i<1;$i++){
			$cog{$arr_class[$i]}{"geneid"}{'p1'}{$arr[0]}="";
			$cogname{$arr_class[$i]}=$arr_fun[$i];
		}

	}else{
		$cog{$class}{"geneid"}{'p1'}{$arr[0]}="";
		$cogname{$class}=$funciton;
	}

}
close IN;


open IN,"plasmid2.cog.list.anno.xls" or die "";
<IN>;
while(<IN>){
	my @arr=split(/\t/,$_);
	$_=~ /(\S+)\t([^\t]+)$/ ;
	my ($class,$funciton)=($1,$2);
	if(length $class >1){
		my @arr_class=split(//,$class);
		my @arr_fun=split(/;/,$funciton);
		for(my $i=0;$i<1;$i++){
			$cog{$arr_class[$i]}{"geneid"}{'p2'}{$arr[0]}="";
			$cogname{$arr_class[$i]}=$arr_fun[$i];
		}

	}else{
		$cog{$class}{"geneid"}{'p2'}{$arr[0]}="";
		$cogname{$class}=$funciton;
	}

}
close IN;
print "cog_class\tcog_function\tchromosome\tplasmid_1\tplasmid_2\n";

foreach my $c(keys %cog){
	my $chr_number=scalar (keys %{$cog{$c}{"geneid"}{"chr"}});
	my $p1_number=scalar (keys %{$cog{$c}{"geneid"}{"p1"}});
	my $p2_number=scalar (keys %{$cog{$c}{"geneid"}{"p2"}});
	my $f=$cogname{$c};
	$f=~ s/\s*$//g;
	my $stat="$c\t$f\t$chr_number\t$p1_number\t$p2_number\n";
	print $stat;
}



