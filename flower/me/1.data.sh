#cd /ifshk5/BC_COM_P8/F12FTSNCKF0308-02/STRhvvD/shouhou_2/adjust_genome_polish/Analysis/05.Comparative_Genomics/Core_Pan/2_S.lydicus.A02/Result/svg
core_num=`cat ../CoreGene.fa|grep \>|wc -l`
cat ../Strain_specific.list|awk -F '\t' '{print $1"\t"$2}'
echo "core	$core_num"
