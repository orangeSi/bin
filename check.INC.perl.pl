#!/usr/bin/perl -w
die "perl $0 <queyr.pm>\n" if(@ARGV!=1);
my $query=shift;
foreach my $k(@INC){
	my $tmp=`find $k|grep $query`;
	print "$k:$tmp\n\n";
}
