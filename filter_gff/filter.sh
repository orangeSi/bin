cat W303_SGD_2015_JRIU00000000.fsa|sed  's/|/_/g' >W303_SGD_2015_JRIU00000000.fsa.new

cat W303_JRIU00000000_SGD.gff |awk  '{if($9!="" && $3!="contig" && $1!~ /^>/)print $0}'|sed 's/ /\t/g' > W303_JRIU00000000_SGD.gff.filter1
perl filter.pl  >W303_JRIU00000000_SGD.gff.filter2
