#!/usr/bin/perl 
die "perl $0 <list;sample gff genome> <prefix> <outdir>\n" if(@ARGV!=3);

my $list=shift;
my $prefix=shift;
my $outdir=shift;

my $sample_num=`wc -l $list|awk '{print \$1}'`;
chomp $sample_num;
my $svg_width=1300;
my $svg_height=1000;

my %genome;
my %gff;
####start:get scaffold length in genome file and scaffold length  in gff file
open LI,"$list" or die "$!";
while(<LI>){
	chomp;
	my ($sample,$gff,$genome)=split(/\s+/,$_);
	open GE,"$genome" or die "$!";
	$/=">";<GE>;
	while(<GE>){
		chomp;
		my ($id,$seq)=split(/\n/,$_,2);
		$id=~ /^(\S+)/;
		$id=$1;
		$seq=~ s/\s+//g;
		my $len=length $seq;
		$genome{$sample}{$id}{len}=$len;
	}
	close GE;
	$/="\n";
	
	open GFF,"$gff" or die "$!";
	my $gene_index;
	while(<GFF>){
		chomp;
		next if($_=~ /^#/);
		my @arr=split(/\t/,$_);
		if(!exists $gff{$sample}{id}{$arr[0]}{len}){
			$gff{$sample}{chooselen}+=$genome{$sample}{$arr[0]}{len};
			$gff{$sample}{id}{$arr[0]}{len}=$genome{$sample}{$arr[0]}{len};
		}
		next if($arr[2] ne "mRNA");
		$gene_index++;
		$gff{$sample}{id}{$arr[0]}{$gene_index}{start}=$arr[3];
		if(!$arr[3]){die "$gff line $.\n"}
		$gff{$sample}{id}{$arr[0]}{$gene_index}{end}=$arr[4];
		$gff{$sample}{id}{$arr[0]}{$gene_index}{strand}=($arr[6]=~ /\+/)? 1:0;


		
	
	}
	close GFF;
}
close LI;
####end:get scaffold length in genome file and scaffold length  in gff file

##start:get max scaffolds lengths in gff file
my $max_length;
my $id_distance_all=0.9;
foreach my $s(sort {$gff{$b}{chooselen}<=>$gff{$a}{chooselen}} keys %gff){
	$max_length=$gff{$s}{chooselen};
	last;
}
my $ratio=$id_distance_all*$svg_width/$max_length;
#print "max is $max_length\n";
##end:get max scaffolds lengths in gff file

my $index;
my $top_bottom_margin=0.1;
open LI,"$list" or die "$!";
my $svg="<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"100%\" height=\"100%\" >\n";
my $top_distance=$top_bottom_margin/2*$svg_height;
while(<LI>){
	chomp;
	$index++;
	my ($sample,$gff,$genome)=split(/\s+/,$_);
	my $sample_single_height=(1-$top_bottom_margin)*$svg_height/$sample_num;
	#
	#my $sample_line_x=10;
	my $id_distance=(1-$id_distance_all)*$svg_width/(scalar(keys %{$gff{$sample}{id}})+1);
#	print "id_distance is $id_distance\n";
	my $flag;
	my $left_distance=$id_distance;
	my $line_to_sample_single_top_dis=0.45;
	my $shift_x=$left_distance;
	foreach my $id(keys %{$gff{$sample}{id}}){
		$flag++;
		my $id_line_x=$left_distance;
		my $id_line_y=$top_distance + $line_to_sample_single_top_dis * $sample_single_height;
#		print "len is $genome{$sample}{$id}{len};id is $id;sample $sample\n";
		my $id_line_width=$genome{$sample}{$id}{len}*$ratio;
		#print "id $id len is $genome{$sample}{$id}{len};ratio is $ratio\n";
		my $id_line_height=(0.5-$line_to_sample_single_top_dis)*2*$sample_single_height;
	
		### draw main scaffold line
		$svg.="<rect x=\"$id_line_x\" y=\"$id_line_y\" width=\"$id_line_width\" height=\"$id_line_height\" style=\"fill:green\"   />\n";
		### add sample name info for every id
		my $line_name_x=$id_line_x+$id_line_width+1;
		my $line_name_y=$id_line_y+$id_line_height;
		my $text_size=$id_line_height *3;
		my $gene_num=scalar(keys %{$gff{$sample}{id}{$id}}) -1;
		$svg.="<text x=\"$line_name_x\" y=\"$line_name_y\" font-size=\"${text_size}px\" fill=\"green\">$sample,${gene_num}genes</text>\n";
		$left_distance+=($id_distance+$ratio*$genome{$sample}{$id}{len});


		### draw genes
		my $gene_height_medium=$id_line_height*1.5;
		my $gene_height_top=$id_line_height*1;
		my $gene_width_arrow=0.3;
		foreach my $index(keys %{$gff{$sample}{id}{$id}}){
			next if($index eq "len");
			$svg.=&draw_genes($gff{$sample}{id}{$id}{$index}{start},$gff{$sample}{id}{$id}{$index}{end},$gff{$sample}{id}{$id}{$index}{strand},$gene_height_medium,$gene_height_top,$gene_width_arrow,$shift_x,$top_distance,$sample_single_height,$sample,$id);
			#print "sampe is $sample,id is $id;index is $index;$gff{$sample}{id}{$id}{$index}{start},$gff{$sample}{id}{$id}{$index}{end},$gff{$sample}{id}{$id}{$index}{strand},$gene_height_medium,$gene_height_top,$gene_width_arrow,$shift_x,$top_distance,$sample_single_height\n";
			
		}
		$shift_x+=($id_line_width+$id_distance);
	}
	$top_distance+=$sample_single_height;
#	$shift_y+= 
#$gff{$sample}{id}{$arr[0]}{$gene_index}{end}=$arr[4]



}
close LI;
open SVG,">test.svg" or die "$!";
print SVG "$svg\n</svg>";
close SVG;
`convert test.svg test.png`;

#$svg.=&draw_genes($gff{$sample}{id}{$id}{$index}{start},$gff{$sample}{id}{$id}{$index}{end},$gff{$sample}{id}{$id}{$index}{strand},$gene_height_medium,$gene_height_top);
sub draw_genes(){
	my ($start,$end,$strand,$gene_height_medium,$gene_height_top,$gene_width_arrow,$shift_x,$shift_y,$sample_single_height,$sample,$id)=@_;
	my ($back,$x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4,$x5,$y5,$x6,$y6,$x7,$y7);
	if($strand){
		$x1=($start*$ratio+$shift_x);$y1=($sample_single_height - $gene_height_medium)/2+$shift_y;
		$x2=$x1;$y2=$y1+$gene_height_medium;
		$x3=$x2+(1-$gene_width_arrow)*($end -$start)*$ratio;$y3=$y2;
		$x4=$x3;$y4=$y3+$gene_height_top;
		$x5=$x2+($end -$start)*$ratio;$y5=0.5*$sample_single_height+$shift_y;
		$x6=$x4;$y6=$y4 - 2*$gene_height_top - $gene_height_medium;
		$x7=$x3;$y7=$y1;
	}else{
		$x1=($start*$ratio+$shift_x);$y1=0.5*$sample_single_height+$shift_y;
		$x2=$x1+$gene_width_arrow*($end -$start)*$ratio;$y2=$y1+0.5*$gene_height_medium+$gene_height_top;
		$x3=$x2;$y3=$y2 -$gene_height_top;
		$x4=$x3+(1-$gene_width_arrow)*($end -$start)*$ratio;$y4=$y3;
		$x5=$x4;$y5=$y4-$gene_height_medium;
		$x6=$x3;$y6=$y5;
		$x7=$x2;$y7=$y2 -2*$gene_height_top - $gene_height_medium;
	
	}
	#print "y1 is $y1\n";
	$back="<g style=\"fill: none\"><title>$sample,$id,$start,$end,$strand</title><polygon points=\"$x1,$y1 $x2,$y2 $x3,$y3 $x4,$y4 $x5,$y5 $x6,$y6 $x7,$y7\" style=\"fill:lime;stroke:purple;stroke-width:0\"/> </g>\n";
	return $back;	

}
