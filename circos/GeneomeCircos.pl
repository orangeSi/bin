#!/usr/bin/perl -w 
use strict;
use Getopt::Long;
use Cwd 'abs_path';
use File::Path;
#================ Getopt::Long =======================
my %par;
GetOptions(\%par,"seq:s","cds:s","rRNA:s","tRNA:s","sample:s","outdir:s","result:s","sRNA:s","AnnoTable:s","CircosPath:s","perl:s");
my $usage=<<USAGE;

Description: Mapping the circle by Circos Program

Usage: perl $0 [options]
	--sample<str>	Sample Name
        --seq<sst>	Assembly sequence
	--cds<str>	gene gff file
	--rRNA<str>	rRNA gff file
	--tRNA<str>	tRNA gff file
	--sRNA<str>	sRNA gff file
	--AnnoTable<str> Anno Table file
	--CircosPath<str> Circos program Path
	--perl<str>	perl program[default:perl]
	--outdir<str>	outdir
	--result<str>	result dir
USAGE
die $usage if (!$par{seq} || !$par{CircosPath});
#================ Main Code ==========================
$par{sample} ||= "Sample";
$par{outdir} ||= ".";
$par{perl} ||="perl";
$par{outdir} = abs_path $par{outdir};mkpath $par{outdir};
$par{result} ||= "$par{outdir}/result";mkpath $par{result};
die "Can't find Circos Program Path " unless -e $par{CircosPath};
my $outdir = $par{outdir};
my (%seq,%length,%colors,%lab,%gene);
#=============== Produce karyotype file
open SEQ,"$par{seq}";
my $all_seq;
$/=">";
<SEQ>;
while(<SEQ>){
	my @line = split '\n',$_;
	my $id =  (split ' ' ,$line[0])[0];
	shift @line;
	my $seq =join '',@line;
	chomp($seq);
	$seq{$id} = $seq;
	$all_seq .= $seq;
	$length{$id} = length($seq);
}
close(SEQ);
$/="\n";
my $temp = " grey green  dgreen  blue dblue purple purple dpurple yellow  dyellow red dred ";
my @keys = keys %length;
my $control = int($#keys/12) +1;
my $colors;
foreach (1..$control){
	$colors .= $temp;
}
my @colors = split ' ',$colors;
foreach my $id (sort {$length{$b} <=> $length{$a}} keys %length){
	open KAR,">$par{outdir}/$id.genome.txt";
	open Seq,">$par{outdir}/$id.sequence.txt";
	open Seq1,">$par{outdir}/$id.sequence1.txt";
	print KAR "chr - hs1 1 0 $length{$id} chr22\n";
	close KAR;
	my $i = 1;
	my ($control,$tag,$step);
	$step = 
	$step = 2500,$tag="kb",$control=1000,if $length{$id} <=25000 && $length{$id} >0 ;
	$step = 5000,$tag="kb",$control=1000,if $length{$id} <=50000 && $length{$id} >25000 ;
	$step = 10000,$tag="kb",$control=1000,if $length{$id} <=100000 && $length{$id} >50000;
	$step = 50000,$tag="kb",$control=1000,if $length{$id} <=1000000 && $length{$id} >100000;
	$step = 500000,$tag="Mb",$control=1000000,if $length{$id} >1000000;
	my $temp = int($length{$id} / 6);
	my @base = split //,$temp;
	my $temp_step = $base[0];
	foreach my $i (1..$#base){
		$temp_step .=0;
	}
	print $temp,"\t",$temp_step,"\n";
	my $temp_lab;
	if($temp_step >=100000){
		$temp_lab = "MB";
		$control=1000000
	}else{
		$temp_lab = "kb";
		$control=1000;
	}
	for ($i = 0;$i<=$length{$id};$i=$i+$temp_step){
		my $lab = int (($i /$control) * 100 ) / 100;
		$lab .="$temp_lab";
		print Seq "hs1 $i $i\n";
		print Seq1 "hs1 $i $i $lab\n";
	}
	close Seq;
	close Seq1;
	$lab{$id} = "hs1";
}

#=============== Produce cds file
my (%CDS,%CDS1,%type);
if($par{cds}){
	open CDS,"$par{cds}";
	my $color_number =1 ;
	my $color;
	while(<CDS>){
		chomp;
		next if /^#/;
		my @line =split '\t',$_;
		if($line[2] =~ /gene/){
			$CDS{$line[0]}{$line[3]} = $_;
			if($line[8] =~ /ID=([^;]+)/){
				$CDS1{$1} = "$line[0]\t$line[3]\t$line[4]";
			}
		}
	}
	close CDS;

	foreach my $chr (sort keys %CDS){
		open FS,">$outdir/$chr.gene.forward.strand" or die "Can't open $chr gene forward\n";
		open All,">$outdir/$chr.gene.All" or die "Can't open $chr gene all\n";
		open RS,">$outdir/$chr.gene.reverse.strand" or die "Can't open $chr reverse strand\n";
		$type{$chr}{ForwardGene} = "$outdir/$chr.gene.forward.strand";
		$type{$chr}{AllGene} = "$outdir/$chr.gene.All";
		$type{$chr}{ReverseGene} = "$outdir/$chr.gene.reverse.strand";
		foreach my $start (sort {$a<=>$b} keys %{$CDS{$chr}}){
			my @line =split /\t/,$CDS{$chr}{$start};
			my $CDS_length = $line[4]  - $line[3] + 1;
			next if $CDS_length > $length{$chr} * 0.8;
			if($line[6] =~ /\+/){
				print FS "$lab{$line[0]} $line[3] $line[4]\n";
				my $temp = $color_number % 2;
				$color = "black",$color_number++ if $temp ;
				$color = "chr24",$color_number++ unless $temp;
				print All "$lab{$line[0]} $line[3] $line[4] $color\n";
			}else{
				my $temp = $color_number % 2;
				$color = "black",$color_number++ if $temp ;
				$color = "chr24",$color_number++ unless $temp;
				print RS "$lab{$line[0]} $line[3] $line[4]\n";
				print All "$lab{$line[0]} $line[3] $line[4] $color\n";
			}
			$CDS{$chr}{$1} = "$line[0]\t$line[3]\t$line[4]" if $line[8] =~ /ID=([^;]+);/;
		}
	}
}

#=============== Produce rRNA file 
if(defined $par{rRNA}){
	my %rRNA;
	open RRNA,"$par{rRNA}" or die "Can't find rRNA file ~~~\n"; 
	while(<RRNA>){
		chomp;
		next if /^#/;
		my @line = split '\t',$_;
		$rRNA{$line[0]}{$line[3]} = $_ if $line[2] =~ /rRNA/;
	}
	close RRNA;
	foreach my $chr (sort keys %rRNA){
		open R,">$outdir/$chr.rRNA.txt";
		$type{$chr}{rRNA} = "$outdir/$chr.rRNA.txt";
		foreach my $start (sort {$a<=>$b} keys %{$rRNA{$chr}}){
			my @line = split /\t/,$rRNA{$chr}{$start};
			print R "$lab{$line[0]} $line[3] $line[4]\n";
		}
		close R;
	}
}

#=============== Produce tRNA file
if(defined $par{tRNA}){
	my %tRNA;
	open TRNA,"$par{tRNA}" or die "Can't find tRNA file ~~~~\n";
	while(<TRNA>){
		chomp;
		next if(/^#/);
		my @line =split '\t',$_;
		$tRNA{$line[0]}{$line[3]} = $_ if $line[2] =~ /tRNA/;
	}
	close(TRNA);
	foreach my $chr (sort keys %tRNA){
		open T,">$outdir/$chr.tRNA.txt";
		foreach my $start (sort {$a<=>$b} keys %{$tRNA{$chr}}){
			my @line = split /\t/,$tRNA{$chr}{$start};
			print T "$lab{$line[0]} $line[3] $line[4]\n";
		}
		close T;
		$type{$chr}{tRNA} = "$outdir/$chr.tRNA.txt";
	}
}

if(defined $par{sRNA}){
         my %sRNA;
         open SRNA,"$par{sRNA}" or die "Can't find sRNA file ~~~~\n";
         while(<SRNA>){
                 chomp;
                 next if(/^#/);
                 my @line =split '\t',$_;
                 $sRNA{$line[0]}{$line[3]} = $_ if $line[2] =~ /sRNA/;
         }
         close(SRNA);
         foreach my $chr (sort keys %sRNA){
                 open S,">$outdir/$chr.sRNA.txt";
                 foreach my $start (sort {$a<=>$b} keys %{$sRNA{$chr}}){
                         my @line = split /\t/,$sRNA{$chr}{$start};
                         print S "$lab{$line[0]} $line[3] $line[4]\n";
                 }
                 close S;
		$type{$chr}{sRNA} = "$outdir/$chr.sRNA.txt";
         }
}

if(defined $par{AnnoTable}){
	my %Anno;
	my @header;
	open Anno,"$par{AnnoTable}" or die "Can't find AnnoTable file ~~~\n";
	while(<Anno>){
		if(/Gene_id/){
			my @line = split /\t/,$_;
			for(my $i =0;$i<=$#line;$i++){
				$line[$i] =~ s/^{//g;
				$line[$i] =~ s/}$//g;
				$header[$i] = $line[$i];
			}
		}else{
			my @line = split /\t/,$_;
			foreach(my $i=1;$i<=$#line;$i++){
				next if $line[$i] =~ /{NA}/;
				if(exists($CDS1{$line[0]})){
					my ($chr,$start,$end) = split /\t/,$CDS1{$line[0]};
					my $CDS_length =  $end - $start;
					next if $CDS_length > $length{$chr} * 0.8;
					$Anno{"$header[$i]\t$chr"}{$start} =$end;
				}
			}
		}
	}
	close Anno;
	my %AllAnnoGene;
	foreach my $type (keys %Anno){
		my ($DataBase,$chr) = split /\t/,$type;
		open OUT,">$outdir/$chr.$DataBase.txt" or die "Can't write $DataBase $chr file\n";
		$type{$chr}{$DataBase} = "$outdir/$chr.$DataBase.txt";
		foreach my $start (sort {$a<=>$b} keys %{$Anno{$type}}){
			print OUT "hs1 $start $Anno{$type}{$start}\n";	
			$AllAnnoGene{$chr}{$start} = "hs1 $start $Anno{$type}{$start}";
		}
		close OUT;
	}
	foreach my $chr (keys %AllAnnoGene){
		open ALL,">$outdir/$chr.AllAnno.txt" or die "Can't write All DataBase $chr file\n";
		$type{$chr}{AllAnno} = "$outdir/$chr.AllAnno.txt";
		foreach my $start (sort {$a<=>$b} keys %{$AllAnnoGene{$chr}}){
			print ALL "$AllAnnoGene{$chr}{$start}\n";
		}
		close ALL;
	}
}

#================ Produce GC and GC_SKEW file
my ($GC_max,$GC_min,$SK_max,$SK_min);
$GC_max = 0;
$GC_min = 1;
$SK_max = 0;
$SK_min = 1;
open Shell,">$outdir/$par{sample}.shell.sh";
foreach my $id (sort {$length{$b} <=> $length{$a}} keys %length){
	open SK,">$outdir/$id.plotSKEW" or die "Write plotSKEW\n";
	open G,">$outdir/$id.plotG" or die "Write plotG\n";
	open C,">$outdir/$id.plotC" or die "Write plotC\n";
	open GC,">$outdir/$id.plotGC" or die "Write plotGC\n";
	my $seq_length = length $seq{$id};
	my ($all_gcs,$all_sks,$all_cs,$all_gs)=&gc_sk($seq{$id});
	print "$all_gcs\n";
	my ($locat,$wind);
	my ($gcs,$sks,$cs,$gs);
	$locat = 0;
	$wind = 10000 if $seq_length >5000000;
	$wind = 5000 if $seq_length <=5000000 && $seq_length > 1000000;
	$wind = 1000 if $seq_length <=1000000 && $seq_length > 500000;
	$wind = 500 if $seq_length <=500000 && $seq_length > 100000;
	$wind = 100 if $seq_length <=100000 && $seq_length >0;
	print "$seq_length\t$wind\n";
	my ($png_seq_lengt) = &Thousands($seq_length);
	while($locat < $seq_length){
		my $sub_seq = substr($seq{$id},$locat,$wind);
		($gcs,$sks,$cs,$gs)=&gc_sk($sub_seq);
		my $temp_gcs;
		my $control = $all_gcs - $gcs;
		$GC_max = $control if $GC_max < $control;
		$GC_min = $control if $GC_min > $control;
		$SK_max = $sks if $SK_max < $sks;
		$SK_min = $sks if $SK_min > $sks;
		if($control >=0){
			$temp_gcs = $control; 
		}else{
			$temp_gcs = "$control";
		}
		my $temp = $locat + $wind;
		if($temp <=$seq_length){
			print SK "hs1\t$locat\t$temp\t$sks\n";
			print G "hs1\t$locat\t$temp\t$gs\n";
			print C "hs1\t$locat\t$temp\t$cs\n";
			print GC "hs1\t$locat\t$temp\t$temp_gcs\n";
		}else{
			print SK "hs1\t$locat\t$seq_length\t$sks\n";
			print G "hs1\t$locat\t$seq_length\t$gs\n";
			print C "hs1\t$locat\t$seq_length\t$cs\n";
			print GC "hs1\t$locat\t$seq_length\t$temp_gcs\n";
		}
		$locat = $temp+1;
	}
	close G;
	close C;
	close GC;
	close SK;

	open OUT1,">$outdir/$id.circos.conf";
	open RE,">$outdir/$id.circos.readme.txt";
	print RE "From inner to outer:\n";
	my $Readme_number =1;
	print OUT1 "
<colors>
<<include etc/colors.conf>>
</colors>

<fonts>
<<include etc/fonts.conf>>
</fonts>

<<include $outdir/$id.ideogram.conf>>
<<include $outdir/$id.ticks.conf>>

<<include etc/housekeeping.conf>>

karyotype = $outdir/$id.genome.txt

<image>
dir = $outdir
file  = $id
png   = yes
svg   = yes
radius         = 1500p
background     = white
auto_alpha_colors = yes
auto_alpha_steps = 5
24bit = yes
angle_offset   = -90
</image>

chromosomes_units           = 0.9

chromosomes_display_default = yes
<highlights>

z = 0

<highlight>
file = $outdir/$id.sequence.txt
r0 = 1r
r1 = 1r +10p
fill_color = lgreen
stroke_thickness = 4
stroke_color = black
</highlight>

";

my $r1;
my $step_r = 0.025;
my $gap = 0.05;
my $r0 = 1;
my $r11;
my $r00;
print RE "$Readme_number\tGenome Size\n";
$Readme_number++;
if($type{$id}{AllAnno}){
	$r1 = $r0 - $step_r;
	$r0 = $r1 - $gap;
	$r00 = $r0 . "r";
	$r11 = $r1 . "r";
	print RE "$Readme_number\tAll Anno Gene\n";
	$Readme_number++;
	print OUT1 "<highlight>
file = $outdir/$id.AllAnno.txt
r0 = $r00
r1 = $r11
fill_color = chr16
</highlight>
";}

if($type{$id}{ForwardGene}){
	$r1 = $r0 - $step_r;
	$r0 = $r1 - $gap;
	$r00 = $r0 . "r";
	$r11 = $r1 . "r";
	print RE "$Readme_number\tForward Stand Gene\n";
	$Readme_number++;
	print OUT1 "<highlight>
file = $outdir/$id.gene.forward.strand
r0 = $r00
r1 = $r11
fill_color = chr7
</highlight>
";}

if($type{$id}{ReverseGene}){
	$r1 = $r0 - $step_r;
	$r0 = $r1 - $gap;
	$r11 = $r1 . "r";
	$r00 = $r0 . "r";
	print RE "$Readme_number\tReverse Stand Gene\n";
	$Readme_number++;
	print OUT1 "<highlight>
file = $outdir/$id.gene.reverse.strand
r0 = $r00
r1 = $r11
fill_color = lgreen
</highlight>
";}

if($type{$id}{tRNA}){
	$r1 = $r0 - $step_r;
	$r0 = $r1 - $gap;
	$r00 = $r0 . "r";
	$r11 = $r1 . "r";
	print RE "$Readme_number\ttRNA\n";
	$Readme_number++;
	print OUT1 "<highlight>
file = $outdir/$id.tRNA.txt
r0 = $r00
r1 = $r11
fill_color = chr14
</highlight>
";}

if($type{$id}{rRNA}){
	$r1 = $r0 - $step_r;
	$r0 = $r1 - $gap;
	$r00 = $r0 . "r";
	$r11 = $r1 . "r";
	print RE "$Readme_number\trRNA\n";
	$Readme_number++;
	print OUT1 "<highlight>
file = $outdir/$id.rRNA.txt
r0 = $r00
r1 = $r11
fill_color = chr19
</highlight>
";}

if($type{$id}{sRNA}){
	$r1 = $r0 - $step_r;
	$r0 = $r1 - $gap;
	$r00 = $r0 . "r";
	$r11 = $r1 . "r";
	print RE "$Readme_number\tsRNA\n";
	$Readme_number++;
	print OUT1 "<highlight>
file = $outdir/$id.sRNA.txt
r0 = $r00
r1 = $r11
fill_color = chr13
</highlight>
";}

if($type{$id}{NRNo} && $id =~ /Plasmid/){
        $r1 = $r0 - $step_r;
        $r0 = $r1 - $gap;
        $r00 = $r0 . "r";
        $r11 = $r1 . "r";
	print RE "$Readme_number\tNR Anno Gene\n";
	$Readme_number++;
        print OUT1 "<highlight>
file = $outdir/$id.NR.txt
r0 = $r00
r1 = $r11
fill_color = chr13
</highlight>
";}

if($type{$id}{KEGGNo} && $id =~ /Plasmid/){
        $r1 = $r0 - $step_r;
        $r0 = $r1 - $gap;
        $r00 = $r0 . "r";
        $r11 = $r1 . "r";
	print RE "$Readme_number\tKEGG Anno Gene\n";
	$Readme_number++;
        print OUT1 "<highlight>
file = $outdir/$id.KEGG.txt
r0 = $r00
r1 = $r11
fill_color = chr19
</highlight>
";}

if($type{$id}{GONo} && $id =~ /Plasmid/){
        $r1 = $r0 - $step_r;
        $r0 = $r1 - $gap;
        $r00 = $r0 . "r";
        $r11 = $r1 . "r";
	print RE "$Readme_number\tGO Anno Gene\n";
	$Readme_number++;
        print OUT1 "<highlight>
file = $outdir/$id.GO.txt
r0 = $r00
r1 = $r11
fill_color = chr14
</highlight>
";}

if($type{$id}{COGNo} && $id =~ /Plasmid/){
        $r1 = $r0 - $step_r;
        $r0 = $r1 - $gap;
        $r00 = $r0 . "r";
        $r11 = $r1 . "r";
	print RE "$Readme_number\tCOG Anno Gene\n";
	$Readme_number++;
        print OUT1 "<highlight>
file = $outdir/$id.COG.txt
r0 = $r00
r1 = $r11
fill_color = chr13
</highlight>
";}

if($type{$id}{SwissProtNo} && $id =~ /Plasmid/){
        $r1 = $r0 - $step_r;
        $r0 = $r1 - $gap;
        $r00 = $r0 . "r";
        $r11 = $r1 . "r";
	print RE "$Readme_number\tSwissProt Anno Gene\n";
	$Readme_number++;
        print OUT1 "<highlight>
file = $outdir/$id.SwissProt.txt
r0 = $r00
r1 = $r11
fill_color = chr19
</highlight>
";}

print OUT1 "

</highlights>

<plots>
";
print RE "$Readme_number\tGC\n";
$Readme_number++;
$r1 = $r0 - $step_r;
$r0 = $r1 - $gap;
$r00 = $r0 . "r";
$r11 = $r1 . "r";
print OUT1 "
<plot>
file    = $outdir/$id.plotGC
type    = line
r0    = $r00
r1    = $r11
min   = 0
max   = $GC_max
fill_under = yes
fill_color = green
thickness = 1
extend_bin = no
</plot>
";

$r1 = $r0;
$r0 = $r1 - $gap;
$r00 = $r0 . "r";
$r11 = $r1 . "r";
print OUT1 "
<plot>
file    = $outdir/$id.plotGC
type    = line
r0    = $r00
r1    = $r11
fill_under = yes
fill_color = red
thickness = 1
min   = $GC_min
max   = 0
extend_bin = no
</plot>
";

print RE "$Readme_number\tGC-SKEW\n";
$Readme_number++;
$r1 = $r0 - $step_r;
$r0 = $r1 - $gap;
$r00 = $r0 . "r";
$r11 = $r1 . "r";
print OUT1 "
<plot>
file    = $outdir/$id.plotSKEW
type    = line
r0    = $r00
r1    = $r11
fill_under = yes
fill_color = chr19
thickness = 1
min   = 0
max   = $SK_max
extend_bin = no
</plot>
";

$r1 = $r0;
$r0 = $r1 - $gap;
$r00 = $r0 . "r";
$r11 = $r1 . "r";
print OUT1 "
<plot>
file    = $outdir/$id.plotSKEW
type    = line
r0    = $r00
r1    = $r11
min   = $SK_min
max   = 0
fill_under = yes
fill_color = chr12
thickness = 1
extend_bin = no
</plot>

<plot>

type  = text
file  = $outdir/$id.sequence1.txt
color = black
r0    = 1r+100p
r1    = 1r+1000p
label_size = 40p
padding    = 0r
rpadding   = -0.25r

</plot>

</plots>

";
	close OUT1;
	close RE;

	open OUT2,">$outdir/$id.ticks.conf";
	print OUT2 "show_ticks          = no
show_tick_labels    = no

<ticks>

radius       = dims(ideogram,radius_outer)
multiplier   = 1/1u
label_offset = 0.4r
color        = black
thickness    = 1p
show_label   = yes

<tick>
spacing        = 100u
size           = 15p
label_size     = 24p
format         = %d
suffix         = Mb
label_offset   = 30p
</tick>

</ticks>
";
	close OUT2;
	open OUT3,">$outdir/$id.ideogram.conf";
	print OUT3 "
<ideogram>

<spacing>

default = 10u
break   = 10u

axis_break_at_edge = yes
axis_break         = yes
axis_break_style   = 2

<break_style 1>
stroke_color = black
fill_color   = blue
thickness    = 0.25r
stroke_thickness = 2
</break>

<break_style 2>
stroke_color     = black
stroke_thickness = 3
thickness        = 1.5r
</break>

</spacing>

# thickness (px) of chromosome ideogram
thickness        = 10p
stroke_thickness = 2
# ideogram border color
#stroke_color     = black
fill             = yes
# the default chromosome color is set here and any value
# defined in the karyotype file overrides it
fill_color       = black

# fractional radius position of chromosome ideogram within image
radius         = 0.85r
show_label     = no
label_with_tag = yes
label_font     = condensedbold
label_radius   = dims(ideogram,radius) + 0.075r
label_size     = 48p

# cytogenetic bands
band_stroke_thickness = 2

# show_bands determines whether the outline of cytogenetic bands
# will be seen
show_bands            = yes
# in order to fill the bands with the color defined in the karyotype
#file you must set fill_bands
fill_bands            = yes

</ideogram>
";
	close OUT3;
	`$par{perl} $par{CircosPath} -conf $outdir/$id.circos.conf`;
	#die "Sample $par{sample} $id circos error :$par{CircosPath} -conf $outdir/$id.circos.conf" if !$?;
	print Shell "$par{perl} $par{CircosPath} -conf $outdir/$id.circos.conf\n";
	open IN,"$outdir/$id.svg";
	open OUT4,">$outdir/$id.new.svg";
	my $temp =1;
	while(<IN>){
		chomp;
		if(/^<text/ && $temp){
			print OUT4 "<text  x=\"50%\" y=\"49%\" dy=\".3em\" fill=\"black\"  font-size=\"50\" text-anchor=\"middle\">$par{sample}</text>\n";
			print OUT4 "<text  x=\"50%\" y=\"51%\" dy=\".3em\" fill=\"black\"  font-size=\"50\" text-anchor=\"middle\">$png_seq_lengt bp</text>\n";
			print OUT4 "$_\n";
			$temp =0;
		}else{
			print OUT4 "$_\n";
		}
	}
	close IN;
	close OUT4;
	`/usr/bin/convert $outdir/$id.new.svg $outdir/$id.new.png`;
	#die "Sample $par{sample} $id convert svg to png  error :/usr/bin/convert $outdir/$id.new.svg $outdir/$id.new.png" if !$?;
	print Shell "/usr/bin/convert $outdir/$id.new.svg $outdir/$id.new.png\n";
	my $ChrType;
	$ChrType = "Genome" if $id =~ /Chromosome/;
	$ChrType = "Plasmid" if $id =~ /Plasmid/;
	`cp $outdir/$id.new.svg $par{result}/$par{sample}.$ChrType.$id.Circos.svg`;
	`cp $outdir/$id.new.png $par{result}/$par{sample}.$ChrType.$id.Circos.png`;
	`cp $outdir/$id.circos.readme.txt $par{result}/$par{sample}.$ChrType.$id.Circos.readme.xls`;
}

################# sub code
sub gc_sk {
    my($seqs)=@_;
    my($gs,$cs,$as,$ts);
    $gs=$cs=$as=$ts=0;
    $gs=($seqs=~tr/[Gg]/N/);
    $cs=($seqs=~tr/[Cc]/N/);
    $as=($seqs=~tr/[Aa]/N/);
    $ts=($seqs=~tr/[Tt]/N/);
    return (0,0,0,0) if(!($gs+$cs));
    return (sprintf("%.5f",($cs+$gs)/($gs+$cs+$as+$ts)),
            sprintf("%.5f",($gs-$cs)/($gs+$cs)),
    	    sprintf("%.5f",($cs)/($gs+$cs+$as+$ts)),
	    sprintf("%.5f",($gs)/($gs+$cs+$as+$ts))
    )
}

sub Thousands{
        my (@Thousands);
        foreach my $data (@_){
                my (@new_data,$new_data,@data,$i,$int,$decimals);
                ($int,$decimals) = (split /\./,$data);
                @data = split //,$int;
                @data = reverse @data;
                my $temp =0;
                foreach  $i (@data){
                        if($temp <3){
                                push @new_data,$i;
                        }else{
                                push @new_data,",";
                                push @new_data,$i;
                                $temp = 0;
                        }
                        $temp++;
                }
                @new_data = reverse @new_data;
                $new_data = join '',@new_data;
                if($decimals){
                        $new_data = $new_data . "." . $decimals;
                }
                push @Thousands,$new_data;
        }
                return @Thousands;
}
