#!/usr/bin/perl  -w
die "perl $0 <.fq or .fq.gz> <outdir> <prefix> <block size:M,this for ATCG,not for file>
example:perl $0 reads.fq.gz . prefix 100
by myth
" if(@ARGV!=4);
use PerlIO::gzip;
use File::Path;


my ($input,$outdir,$prefix,$block_size)=@ARGV;
mkpath $outdir if(! -d $outdir);

my $index=1;
my $limit=$block_size *1000000;
my $flag;
open IN,"<:gzip(autopop)","$input" or die "$!";
open OUT,"|gzip >$outdir/$prefix.$index.fq.gz" or die "$!";
my $head=<IN>;my $seq=<IN>;
my $tag=<IN>;
my $qv=<IN>;
chomp $seq;
print OUT "$head$seq\n$tag$qv";
my $read_len=length $seq;
while(<IN>){
    chomp;
    $head=$_;
    $seq=<IN>;chomp $seq;
    $tag=<IN>;chomp $tag;
    $qv=<IN>;chomp $qv;
    $flag+=length $seq;
    if($flag<$limit){
        print OUT "$head\n$seq\n$tag\n$qv\n";
        }else{
            close OUT;
            $index++;
            open OUT,"|gzip >$outdir/$prefix.$index.fq.gz" or die "$!";
            print OUT "$head\n$seq\n$tag\n$qv\n";
            $flag=0;
            }
    
}
close IN;
close OUT;
