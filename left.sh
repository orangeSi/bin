
asslist=ass.list
mkdir Process
cd Process
ln -s ../Process/Filte* ../Process/Kmer_Analysis .
cd ..
/ifshk7/BC_PS/yanglin1/Pipeline/Bacteria_Complete_Genome/Bacteria_Complete_Genome_2015d/AnalysisModule/CorrectByHiseq/bin/AssemblyStat.pl --Falst $asslist --output ass_stat.xls
mkdir upload/Abstract -p
cp ass_stat.xls upload/Abstract/Assembly.stat.xls 
mkdir Process/Correct_ByHiseq/List -p
cp ass_stat.xls Process/Correct_ByHiseq/List/Assemble.stat.xls

cat $asslist|while read x;
do
	sample=`echo $x |awk '{print $1}'`
	ass=`echo $x |awk '{print $2}'`
	mkdir -p Process/Correct_ByHiseq/$sample/CorrectResult
	cp $ass Process/Correct_ByHiseq/$sample/CorrectResult/$sample.genome.fa
	cat ass_stat.xls|awk -v sample=$sample '{if($1==sample){print $0}}' >Process/Correct_ByHiseq/$sample/CorrectResult/$sample.ass_stat.xls


done

# sh Step3.Report.sh
