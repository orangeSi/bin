#!/usr/bin/perl -w

die "perl $0 <dep.txt> <yes or key word in script name which don't run> <outprefix> <foreach number;default 10>\n" if(@ARGV!=4);

my $dep=shift;
my $key=shift;
my $prefix=shift;
my $loop=shift;
$loop ||=10;
my %deps;
my %mems;
my %trys;
my %runtimes;
my $limit=3;

open DEP,"$dep" or die "$!";
while(<DEP>){
	chomp;
	next if($key ne "yes" && $_=~ /$key/);
	if($_!~ /\t/){
		
		if($_=~ /^([^:]+):([^G]+)G?$/){
			$deps{$1}{""}="";
			$mems{$1}=$2;
		}else{
			die "die:$_\n";
		}
	}else{
		if($_=~ /^([^:]+):([^G]+)G?\t([^:]+):([^G]+)G?$/){
			$deps{$3}{"$1"}="";
			$deps{$1}{""}="";# add
			$mems{$1}=$2;
			$mems{$3}=$4;
		}else{
			die "die:$_\n";
		}
		
	}
}
close DEP;

open LOG,">$prefix.local.log" or die "$!";
open ERR,">$prefix.local.err" or die "$!";


foreach my $l(1..$loop){
	foreach my $job(sort {$mems{$a}<=>$mems{$b}} keys %deps){
		my $flag=0;
		my $dep_num;
		foreach my $dep(keys %{$deps{$job}}){
			$dep_num++;
			if($dep  eq ""){
				$flag++;
				next		
			}else{
				if ( -f "$dep.sign"){
					$flag++;
					next
				}
			}
		}

		$trys{$job}=0 if(! exists $trys{$job});
		next if(! -f "$job");## add
		if($flag == $dep_num && ! -f "$job.sign"){
			if($trys{$job} <=$limit){
				my $free=`free |head -2|tail -1|awk '{print \$4/1000000}'`;chomp $free;
				my $free_swap=`free |tail -1|awk '{print \$4/1000000}'`;chomp $free_swap;
				
				if(($free >0.1 && $free_swap > $mems{$job}*5)){
					`sh $job >$job.o123 2>$job.e123`;								
					print LOG "run $trys{$job}th:$job\n";
					$runtimes{$job}++;
				}else{
					print ERR "memory not enough:$free,$free_swap,$mems{$job},$job \n";
				}	
			}elsif($runtimes{$job}> $limit){	
				print ERR "more than $limit.th:$job\n";
							
			}
			$trys{$job}++;
		}
	}
}
close LOG;
close ERR;
