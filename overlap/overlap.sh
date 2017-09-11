rRNA=CQ16Z2A.denovo.rRNA.gff
tRNA=CQ16Z2A.tRNA.gff
sRNA=CQ16Z2A.sRNA.cmsearch.confident.nr.gff
glimmer=CQ16Z2A.glimmer.gff

cat $rRNA|awk -F '\t' '{if($1!~ /^#/)print $1"\t"$4"\t"$5"\t"$9}' >rRNA.bed
cat $tRNA|awk -F '\t' '{if($1!~ /^#/)print $1"\t"$4"\t"$5"\t"$9}' >tRNA.bed
cat $sRNA|awk -F '\t' '{if($1!~ /^#/)print $1"\t"$4"\t"$5"\t"$9}' >sRNA.bed

cat $glimmer|awk -F '\t' '{if($3 == "gene")print $1"\t"$4"\t"$5"\t"$9}' >gene.bed

export PATH=/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/bedtools2-2.25.0/bin:$PATH

for i in rRNA.bed tRNA.bed sRNA.bed
do
	    bedtools intersect -a gene.bed  -b $i -wo -f 1E-9 >$i.out
    done




