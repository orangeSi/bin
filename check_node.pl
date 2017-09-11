#!/usr/bin/perl -w
use strict;
die "perl $0 <compute-25-4.local> <compute-25-1.local> <....>\n"if(@ARGV==0);
foreach my $hosts(@ARGV){
        chomp $hosts;
        my $temp;
        my $count=0;
		my ($totalusage,$totalmax)=(0,0);
        if($hosts=~/(\S+.loc)$/){$temp=$1."al";}
        else{$temp=$hosts;}
        my @lines1=`qhost -h $temp`;
        foreach(@lines1){if(/\d+(\.\d+)?G/){print "$_";}}
        my @lines2=`qstat -u \\* |grep $hosts`;
        foreach(@lines2){
                s/^\s+//;
                my @aa=split /\s+/,$_;
                printf "%-10s%-12s%-12s",$aa[0],$aa[2],$aa[3];
                `qstat -j $aa[0] >~/my_check_node.tmp`;
                my $resou=`grep resource_list ~/my_check_node.tmp`;
                $resou=$1 if $resou=~/virtual_free=([^\s]+)$/;
                if($resou=~/(\d+(\.\d+)?)G/i){$count+=$1;}
                elsif($resou=~/(\d+(\.\d+)?)m/i){$count+=$1/1000;}
                elsif($resou=~/(\d+(\.\d+)?)k/i){$count+=$1/1000000;}
                else{print "$resou is not the normal data!\n";}
                my $max=`grep 'usage' ~/my_check_node.tmp`;
				my $mem=$1 if $max=~/vmem=([^,]+)/;
				if($mem=~/(\d+(\.\d+)?)G/i){$totalusage+=$1;}
				elsif($mem=~/(\d+(\.\d+)?)m/i){$totalusage+=$1/1000;}
				elsif($mem=~/(\d+(\.\d+)?)k/i){$totalusage+=$1/1000000;}
				else{print "$mem is not the normal data!\n";}
                my $times=$1 if $max=~/cpu=((\d+:)?(\d+:)?\d+:\d+:\d+)/;
                $max=$1 if $max=~/maxvmem=([^\s]+)$/;
                printf "resou=%-16s",$resou;
                printf "mem=%-10smax=%-10scpu=%-15s\n",$mem,$max,$times;
				if($max=~/(\d+(\.\d+)?)G/i){$totalmax+=$1;}
				elsif($max=~/(\d+(\.\d+)?)m/i){$totalmax+=$1/1000;}
				elsif($max=~/(\d+(\.\d+)?)k/i){$totalmax+=$1/1000000;}
				else{print "$max is not the normal data!\n";}
                }
        print "Total virtual_resou $count G\nTotal used resou $totalusage G\nTotal max resou $totalmax G\n";
        }
`rm -f ~/my_check_node.tmp`;

