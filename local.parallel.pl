#!/usr/bin/perl -w

die "perl $0 
<dep.txt>
<runall or key word in script name which don't want to run> 
<outprefix>
<cpu usage limit;ex 60> 
<swap usage:ex 30>
\n" if(@ARGV!=5);

my $dep=shift;
my $key=shift;
my $prefix=shift;
#my $parallel_limit=shift;
my $cpu_limit=shift;
my $swap_usage_limit=shift;
#$parallel_limit ||=2;
my $sleep =10;
#$cpu_limit ||=60;

my $running_number=0;
my %local;
my %runs;
my $limit=3;
my $cost_mem=0;
my $cpu;
my $loop;
my $flag=0;

open DEP,"$dep" or die "$!";
while(<DEP>){
	chomp;
	next if($key ne "runall" && $_=~ /$key/);
	if($_!~ /\t/){
		
		if($_=~ /^([^:]+):([^G]+)G?$/){
			$local{$1}{dep}{""}="";
			$local{$1}{mem}=$2;
		}else{
			die "die:$_\n";
		}
	}else{
		if($_=~ /^([^:]+):([^G]+)G?\t([^:]+):([^G]+)G?$/){
			$local{$3}{dep}{"$1"}="";
			$local{$1}{dep}{""}="";#add
			$local{$1}{mem}=$2;
			$local{$3}{mem}=$4;
		}else{
			die "die:$_\n";
		}
		
	}
}
close DEP;
$loop=scalar (keys %local);

open LOG,">$prefix.local.log" or die "$!";
open ERR,">$prefix.local.error" or die "$!";

my $l;
my $life;
while(!$flag){
	$l++;
	$flag=1;
	foreach my $job(sort {$local{$a}{mem}<=>$local{$b}{mem}} keys %local){
		my $flag1=0;
		my $dep_num=0;
		foreach my $dep(keys %{$local{$job}{dep}}){
			$dep_num++;
			if($dep  eq ""){
				$flag1++;
				next		
			}else{
				if ( -f "$dep.sign"){
					$flag1++;
					next
				}
			}
		}
#		$local{$job}{try}=0 if(! exists $local{$job}{try});
		next if(! -f "$job");
		$local{$job}{stat}="null" if(! exists $local{$job}{stat});
		$local{$job}{runtimes}=0 if(! exists $local{$job}{runtimes});
		if($flag1 == $dep_num && ! -f "$job.sign"){
			die "die:$job not exist~\n" if( ! -f "$job");
			$flag=0;
			if($local{$job}{runtimes} <=$limit && $local{$job}{stat} ne "running"){
				my $free=`free |head -2|tail -1|awk '{print \$4/1000000}'`;chomp $free;
				my $free_swap=`free |tail -1|awk '{print \$4/1000000}'`;chomp $free_swap;
				my $swap=`free|tail -1|awk '{print \$2/1000000}'`;chomp $swap;
				foreach my $k(%runs){
					next if(!$k);
					#$life=`ps f|awk   '{if(\$3!~ /T/ &&  \$3!~ /Z/){print \$0}else{print 0}}'|grep "$k"|wc -l`;chomp $life;			      
					next if(exists $runs{$k}{done});
					$life=`ps f|grep "$k"|awk   '{if(\$3!~ /T/ &&  \$3!~ /Z/){print 1}else{print 0}}'|sort -u`;chomp $life;
					
					print "life if $life,$k\n";
					#print LOG `ps axf`;	
					if(!$life){
						$cost_mem= $cost_mem - $local{$k}{mem} * 3;
						$runs{$k}{done}="";
						if(-f "$k.sign"){
							$local{$job}{stat}="done";
						}
					}
				}
				`sleep $sleep`;
				$free_swap =$free_swap - $cost_mem - $local{$job}{mem} * 3;
				my $swap_usage=(1-$free_swap/$swap)*100;
#				my $time_ls=`(time ls &>/dev/null) 2>&1 |head -2 |tail -1|grep real|awk '{print \$2}'|awk -F '[ms]' '{print \$2}'`;chomp $time_ls;
				$cpu=`mpstat 2 3 >$prefix.local.tmp; cat $prefix.local.tmp|tail -5 |sort -k 4nr|head -1|awk '{print \$4}'`;chomp $cpu;
#				$cpu=`cat /proc/stat|grep cpu|awk '{i=\$2/(\$2+\$3+\$4+\$5+\$6+\$7+\$8+\$9)*100;j=j+i;}END{print j}'`;chomp $cpu;
				$cpu=($cpu)? $cpu:100;
				$cpu+=5;## to moni real cpu after run $job ~
				if($free >0.1 && $free_swap > $local{$job}{mem}*4 && $swap_usage <$swap_usage_limit  && $cpu < $cpu_limit){
					`sh $job >$job.o123 2>$job.e123 &`;	
					`sleep $sleep`;## to get near real cpu of previus job	
					#my $pid=`ps f|grep 'sh $job >$job.o123 2>$job.e123'|awk '{if(\$3~ /R/ || \$3~ /S/)}'|head -1|awk '{print \$1}'`;chomp $pid;
#					my $pid=`ps f|grep 'sh $job '|awk '{if(\$3!~ /T/ )print \$0}'|head -1|awk '{print \$1}'`;chomp $pid;
#					$pid ||= 0;
#					$local{$job}{pid}=$pid;
					$runs{$job}{stat}="run";
					
					#$running_number++;
					$cost_mem+=$local{$job}{mem}*3;
					$local{$job}{stat}="running";
					$local{$job}{pid}=$pid;
					print LOG "$l th;running $job; before this:$local{$job}{runtimes}th free$free,free_swap$free_swap,cost_mem$cost_mem,local.job.mem$local{$job}{mem},swap_usage$swap_usage,swap_usage_limit$swap_usage_limit,cpu$cpu\n";
					$local{$job}{runtimes}++;
				#}elsif($free <0.1 || $free_swap < $local{$job}{mem}*4){
				}else{
					`echo "$l th;memory or cpu not enough:free$free,free_swap$free_swap,cost_mem$cost_mem,local.job.mem$local{$job}{mem},swap_usage$swap_usage,swap_usage_limit$swap_usage_limit,cpu$cpu :$job" >$prefix.local.wait ;sleep $sleep`;
#				}elsif($running_number >= $parallel_limit){
#					print LOG "$l th;sleep $sleep;$running_number >= $parallel_limit,cpu is $cpu,$job\n";
##					`sleep $sleep`;
#				}elsif($cpu >= $cpu_limit){
#					print LOG "$l th;sleep $sleep;$running_number >= $parallel_limit,cpu is $cpu,$job\n";
#					`sleep $sleep`;
				}	
			}elsif($local{$job}{runtimes}> $limit){	
				print ERR "$l th;more than $limit.th:$job\n";
							
			}

		}
			#elsif(-f "$job.sign"){
#			if($local{$job}{stat} eq "running"){
#				$local{$job}{stat}="done";
#				$cost_mem-=$local{$job}{mem}*3;
				#$running_number--;

#			}
				
#		}
	}
	if($flag){print LOG "done\n";exit}
}
close LOG;
close ERR;
