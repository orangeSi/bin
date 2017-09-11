base=$PWD
for  i in 2 4 5 6
do
	cd $base
#	cp ../Result/Result/Separate/SEM-${i}A/2.Assembly/SEM-${i}A.agp SEM-$i/SEM-$i.agp
#	cp ../Result/Result/Separate/SEM-${i}A/2.Assembly/SEM-${i}A.contig SEM-$i/SEM-$i.contig
	cp ../Result/Result/Separate/SEM-${i}A/2.Assembly/SEM-${i}A.seq SEM-$i/SEM-$i.seq

#	cp SEM-$i.template.sbt SEM-$i/
#	cd $base/SEM-$i/
#	echo "/ifshk7/BC_PS/sikaiwei/assembly/ncbi_tools/tbl2ans/linux64.tbl2asn  -i SEM-$i.contig -t SEM-$i.template.sbt -V v -Z log -j \"[organism=Cyanobacteria][strain=Cyanobacteria TDX16]\" -a s">work.SEM-$i.sh


done
