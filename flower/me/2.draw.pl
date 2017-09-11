#!/usr/bin/perl -w
my $width=1000;
my $height=1000;
my $xcentre=$width/2;
my $ycentre=$height/2;
my $R=0.2*$width;
my $pi = 4*atan2(1, 1);

my @refs;my %numbers;my $core_num;
open IN,"1.data" or die "$!";
while(<IN>){
	chomp;
	my @arr=split(/\t/,$_);
	if($arr[0] eq "core"){$core_num=$arr[1]}
	$refs[$.-1]=$arr[0];
	$numbers[$.-1]=$arr[1];
}
close IN;


print "<svg width=\"${width}px\" height=\"${height}px\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n";
my $num=scalar(@refs)-1;
my $x=0.5*$width;
my $y=(0.5-0.2)*$width;
my $ry=$R*1.1;
my $rx=0.3*$ry;

my $index=0;
foreach my $ref(@refs){
	next if($ref eq "core");
	$index++;
	my $angle=360/$num * ($index -1);
	my $opacity=0.5+0.4*$index/$num;
	my $x_lable=$xcentre + sin($angle*$pi/180)*2.2*$R;#弧度转为弧度值
	my $y_lable=$ycentre - cos($angle*$pi/180)*2.2*$R;#弧度转为弧度值
	#print "angle is $angle\n";
	#print "x:$x,y:$y\n";
	print "<ellipse cx=\"$x\" cy=\"$y\" rx=\"$rx\" ry=\"$ry\" style=\"fill:purple;fill-opacity:$opacity\" transform=\"rotate($angle, $xcentre $ycentre)\" />\n";##cy,cx是椭圆中心，rx,ry是长高
	#my $angle_lable=$angle+270;
	
	my $x_number=$xcentre + sin($angle*$pi/180)*1.8*$R;#弧度转为弧度值
	my $y_number=$ycentre - cos($angle*$pi/180)*1.8*$R;#弧度转为弧度值
	my $angle_lable=($angle>90 && $angle<270)? ($angle+180):$angle;##当angel旋转到下半球的时候，自动加上180度旋转使lable能被
	my $ref_new_name;
	if($ref=~ /^(\S\. \S+)( .*)$/){
		$ref_new_name="<tspan font-style=\"italic\">$1</tspan><tspan>$2</tspan>";
	}else{
		$ref_new_name="<tspan font-style=\"italic\">$ref</tspan><tspan></tspan>";
	}
	print "<text x=\"$x_lable\" y=\"$y_lable\" transform=\"rotate($angle_lable, $x_lable $y_lable)\" style=\"font-size:18;text-anchor:middle;dominant-baseline:middle\">$ref_new_name</text>\n";### ref 名称
	print "<text x=\"$x_number\" y=\"$y_number\" transform=\"rotate($angle_lable, $x_number $y_number)\" style=\"font-size:20;text-anchor:middle;dominant-baseline:middle\" >$numbers[$index -1]</text>\n"; ## ref 特有基因数目
	
	

}
my $r=0.3*$R;
print "<ellipse cx=\"$xcentre\" cy=\"$ycentre\" rx=\"$r\" ry=\"$r\" style=\"fill:purple;fill-opacity:1\" />\n";##cy,cx是椭圆中心，rx,ry是长高
print "<text x=\"$xcentre\" y=\"$ycentre\" style=\"font-size:20;fill:yellow;fill-opacity:1;text-anchor:middle;dominant-baseline:middle\" >$core_num</text>\n";##共有基因数目
print "</svg>\n";
