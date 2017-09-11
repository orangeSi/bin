#!/usr/bin/perl 

die "perl $0 <bin dir>\n" if(@ARGV!=1);

my $dir=shift;

foreach my $k(`cd $dir;find $dir -type f`){
	chomp $k;
	my $type=`cd $dir;file $k|grep executable|wc -l`;chomp $type;
	if($type >=1){
		my $num=`cd $dir;ldd $i &>log && cat log|grep 'not found'|wc -l`;chomp $num;
		if($num>=1){
			print "$k\n";
		}
	}

}
