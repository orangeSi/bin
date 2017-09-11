base=/ifshk5/BC_COM_P8/F16FTSECKF2774/VIRxrmE/rawdata/Result/Separate/
builer_memory=1G
soap_memory=1G
cpu=2


JEV=/ifshk5/BC_COM_P8/F16FTSECKF2774/VIRxrmE/rawdata/011.map2ref/ref/JEV.fna
pre=JEV
outdirp=$PWD/process
outdirs=$PWD/shell
mkdir -p $outdirp $outdirs

echo "/ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/BAC_pipeline_1.1.1/Assembly/Assembly_V2.4/lib/SOAP2/2bwt-builder $JEV && ">$outdirs/$pre.buider.sh
sh /ifshk7/BC_PS/sikaiwei/bin/add.header.tail.for.monitor.sh $outdirs/$pre.buider.sh
echo $outdirs/$pre.buider.sh:$builer_memory >dep.list
for  i in C6_36_C13A C6_36_C15A C6_36_C18A C6_36_C19A C6_36_C7A
do
	r1=`ls $base/$i/1*/*1.fq.gz`
	r2=`ls $base/$i/1*/*2.fq.gz`
	echo "/ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/BAC_pipeline_1.1.1/Assembly/Assembly_V2.4/lib/SOAP2/soap2.21 -a $r1 -b $r2 -D $JEV.index -o $outdirp/$pre.$i.sensitive.pe -2 $outdirp/$i.sensitive.se -m 100 -x 400 -l 20 -s 90 -v 8 -p $cpu && ">$outdirs/$i.soap.sensitive.sh
	echo "/ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/BAC_pipeline_1.1.1/Assembly/Assembly_V2.4/lib/SOAP2/soap2.21 -a $r1 -b $r2 -D $JEV.index -o $outdirp/$i.not.sensitive.pe -2 $outdirp/$i.not.sensitivese.se -m 100 -x 400 -l 30 -s 100 -v 5 -p $cpu && ">$outdirs/$i.soap.not.sensitive.sh
	echo "$outdirs/$pre.buider.sh:$builer_memory	$outdirs/$i.soap.sensitive.sh:$soap_memory">>dep.list
	echo "$outdirs/$pre.buider.sh:$builer_memory	$outdirs/$i.soap.not.sensitive.sh:$soap_memory">>dep.list
	sh /ifshk7/BC_PS/sikaiwei/bin/add.header.tail.for.monitor.sh $outdirs/$i.soap.sensitive.sh
	sh /ifshk7/BC_PS/sikaiwei/bin/add.header.tail.for.monitor.sh $outdirs/$i.soap.not.sensitive.sh

done

BANNA=/ifshk5/BC_COM_P8/F16FTSECKF2774/VIRxrmE/rawdata/011.map2ref/ref/BANNA.fna
pre=BANNA
echo "/ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/BAC_pipeline_1.1.1/Assembly/Assembly_V2.4/lib/SOAP2/2bwt-builder $BANNA && ">$outdirs/$pre.buider.sh
echo $outdirs/$pre.buider.sh:1G >>dep.list
sh /ifshk7/BC_PS/sikaiwei/bin/add.header.tail.for.monitor.sh $outdirs/$pre.buider.sh
for  i in 6纯2A JEV-2A
do
	r1=`ls $base/$i/1*/*1.fq.gz`
	r2=`ls $base/$i/1*/*2.fq.gz`
	echo "/ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/BAC_pipeline_1.1.1/Assembly/Assembly_V2.4/lib/SOAP2/soap2.21 -a $r1 -b $r2 -D $BANNA.index -o $outdirp/$i.sensitive.pe -2 $outdirp/$i.sensitive.se -m 100 -x 400 -l 20 -s 90 -v 8 -p $cpu && ">$outdirs/$i.soap.sensitive.sh
	echo "/ifshk4/BC_PUB/biosoft/pipe/bc_mg/BAC_Denovo/BAC_pipeline_1.1.1/Assembly/Assembly_V2.4/lib/SOAP2/soap2.21 -a $r1 -b $r2 -D $JEV.index -o $outdirp/$i.not.sensitive.pe -2 $outdirp/$i.not.sensitivese.se -m 100 -x 400 -l 30 -s 100 -v 5 -p $cpu  && ">$outdirs/$i.soap.not.sensitive.sh
	echo "$outdirs/$pre.buider.sh:$builer_memory	$outdirs/$i.soap.sensitive.sh:$soap_memory">>dep.list
	echo "$outdirs/$pre.buider.sh:$builer_memory	$outdirs/$i.soap.not.sensitive.sh:$soap_memory">>dep.list
	sh /ifshk7/BC_PS/sikaiwei/bin/add.header.tail.for.monitor.sh $outdirs/$i.soap.sensitive.sh
	sh /ifshk7/BC_PS/sikaiwei/bin/add.header.tail.for.monitor.sh $outdirs/$i.soap.not.sensitive.sh
done





