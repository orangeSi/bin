if [ "$3" == "" ];
then
	echo "sh $0 <bms> <v3-v4 or v1-v3 or v4-v5 or v4> <rawdata>"
	exit

fi

if [ "$2" == "v3-v4" ];
then
	F=ACTCCTACGGGAGGCAGCAG
	R=GGACTACHVGGGTWTCTAAT
fi

if [ "$2" == "v1-v3" ];
then
	F=AGAGTTTGATYMTGGCTCAG
	R=ATTACCGCGGCTGCTGG
fi

if [ "$2" == "v4-v5" ];
then
	F=GTGCCAGCMGCCGCGG
	R=CCGTCAATTCMTTTRAGT
fi


if [ "$2" == "v4" ];
then
	echo "#SampleName       LibraryName     RawdataPath     Description"
else
	echo "#SampleName	LibraryName	RawdataPath	Description	group2	ForwardPrimer	ReversePrimer"
fi

cat $1|sed -r 's/\t/ORANGED/g'|while read i;
do	
	lib=`echo $i|awk -F 'ORANGED' '{print $3}'`
	sample=`echo $i|awk -F 'ORANGED' '{print $2}'`
	rawdata=`ls $3/*/*$lib/1.adapter.list.gz`
	rawdir=`dirname $rawdata`
	

	if [ "$2" == "v4" ];
	then
		echo "$sample	$lib	$rawdir	Description"
	else
		echo "$sample	$lib	$rawdir	Description	group2	$F	$R"
	
	fi

done
