#!/bin/bash

output=$PWD/upload//F16FTSAPHT0808_BACjpqM
list=ass.list
bin=/ifshk7/BC_PS/sikaiwei/bin/meta/
##list format is : samplename seq seqpath
cat $list|sed 's/\t/ORANGE/g'|while read line;
do
	sample=`echo $line|awk -F 'ORANGE' '{print $1}'`
	genome=`echo $line|awk -F 'ORANGE' '{print $3}'`
	mkdir $output/shell/$sample/ -p
	echo "mkdir $output/$sample/;perl $bin/get_scaftig.pl $genome  500 > $output/$sample/$sample.scaftig.fa  && perl $bin/N50.pl --fa $output/$sample/$sample.scaftig.fa  --cutoff 499 --sample $sample --kmer mink21.maxk101 --outprefix $output/$sample/$sample.scaftig  && " >$output/shell/$sample/stat.sh
	echo "
	a <- read.table(\"$output/$sample/$sample.scaftig.length\")
	pdf(\"$output/$sample/$sample.scaftig.length.pdf\", height=7, width=7)
	par(mar=c(7,6,4,2), mgp=c(3.5,0.5,0))
	bar=barplot(a\$V2, ylim=c(0,1.2*max(a\$V2)), col=\"#1874CD\", cex.main=1.4, cex.lab=1.4, xlab=\"\", ylab=\"Sequence Number\", main=\"Contig Length Distribution of sample1\",las=2)
	text(bar, a\$V2+0.05*max(a\$V2), srt=90, labels=a\$V2, xpd=T, cex=0.8, pos=4, offset=0)
	axis(1, labels = FALSE, at=bar)
	text(bar, par(\"usr\")[3] - 0.05*max(a\$V2), srt = 45, adj = 1, labels = a\$V3, xpd = TRUE)
	mtext(1, text = \"Sequence Length (bp)\", cex=1.4, line = 5.5)
	box(bty=\"l\")
	dev.off()
	" >$output/shell/$sample/scaftig.length.R
	echo "/ifshk7/BC_PS/sikaiwei/assembly/R/R-3.3.1_install/bin/Rscript  $output/shell/$sample/scaftig.length.R ;convert $output/$sample/$sample.scaftig.length.pdf $output/$sample/$sample.scaftig.length.png ;cd $output;tar cjf $sample.tar.bz2 $sample && md5sum $sample.tar.bz2 >md5.txt.assembly.$sample && rm -rf $sample" >>$output/shell/$sample/stat.sh




done
