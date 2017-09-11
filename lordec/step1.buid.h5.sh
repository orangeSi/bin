. /ifshk7/BC_PS/sikaiwei/assembly/LoRDEC/LoRDEC-0.6/path.sh
sr=/opt/lustresz/BC_PMO_P0/BC_RD/dengtq/zaotai_cleandata/01.illumina_High_Qvalue_20_0/SZAIPI009888-44_1.fq_500.clean.fq.gz.clean.gz,/opt/lustresz/BC_PMO_P0/BC_RD/dengtq/zaotai_cleandata/01.illumina_High_Qvalue_20_0/SZAIPI009888-44_2.fq_500.clean.fq.gz.clean.gz,/opt/lustresz/BC_PMO_P0/BC_RD/dengtq/zaotai_cleandata/01.illumina_High_Qvalue_20_0/SZAXPI012688-74_1.fq_800.clean.fq.gz.clean.gz,/opt/lustresz/BC_PMO_P0/BC_RD/dengtq/zaotai_cleandata/01.illumina_High_Qvalue_20_0/SZAXPI012688-74_2.fq_800.clean.fq.gz.clean.gz,/opt/lustresz/BC_PMO_P0/BC_RD/dengtq/zaotai_cleandata/01.illumina_High_Qvalue_20_0/SZAXPI035948-13_1.fq_250.clean.fq.gz.clean.gz,/opt/lustresz/BC_PMO_P0/BC_RD/dengtq/zaotai_cleandata/01.illumina_High_Qvalue_20_0/SZAXPI035948-13_2.fq_250.clean.fq.gz.clean.gz

lordec-build-SR-graph -T 10 -2 $sr -k 19 -s 3  -g out.h5

