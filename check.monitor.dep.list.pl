die "perl $0 <dep.list>\n" if(@ARGV!=1);
my $dep=shift;
open IN,"$dep" or die "$!";
while(<IN>){
	chomp;
	my $line=$_;
	unless($line=~ /^(\S+):[\d\.]+G\t(\S+):[\d\.]+G$/){
		die "line:$line:\n";
	}elsif(! -e $1 or ! -e $2){
		die "$1 or $2 not exist~\n";
	}


}
close IN;
