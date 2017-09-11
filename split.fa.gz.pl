#!/usr/bin/perl -w
die "perl $0 <.fa or .fa.gz> <outdir> <prefix> <block size:M,this for ATCG,not for file> <min length,default=0>
example:perl $0 reads.fa.gz . prefix 100
by myth
" if(@ARGV!=5);
use PerlIO::gzip;
use File::Path;


my ($input,$outdir,$prefix,$block_size,$min)=@ARGV;
mkpath $outdir if(! -d $outdir);
$min=($min)? $min:0;
print "min length:$min\n";
my $index=1;
my $limit=$block_size *1000000;
my $flag;
open IN,"<:gzip(autopop)","$input" or die "$!";
open OUT,"|gzip >$outdir/$prefix.$index.fa.gz" or die "$!";
$/="\n>";
while(<IN>){
    chomp;
    my ($title,$seq)=split(/\n/,$_,2);
    $title=~ s/^>+//;
    $seq=~ s/\s+//g;
    next if(length $seq <$min);
    $flag+=length $seq;
    if($flag<$limit){
        print OUT ">$title\n$seq\n";
        }else{
            close OUT;
            $index++;
            open OUT,"|gzip >$outdir/$prefix.$index.fa.gz" or die "$!";
            print OUT ">$title\n$seq\n";
            $flag=0;
            }
    
}
close IN;
close OUT;
