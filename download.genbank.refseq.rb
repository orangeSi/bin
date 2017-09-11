#!/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/Ruby/install/bin/ruby -W0
if ARGV.length !=1
	puts "usage: <base_url:ex ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF_000340785.1_ASM34078v1>"
	exit
end

base=`basename #{ARGV[0]}`.chomp
target="wget #{ARGV[0]}/#{base}"+"_genomic.gbff.gz >#{base}.o 2>#{base}.e \n"
target+="wget #{ARGV[0]}/#{base}"+"_cds_from_genomic.fna.gz >>#{base}.o 2>>#{base}.e \n"
target+="wget #{ARGV[0]}/#{base}"+"_genomic.fna.gz >>#{base}.o 2>>#{base}.e  \n"
target+="wget #{ARGV[0]}/#{base}"+"_protein.faa.gz >>#{base}.o 2>>#{base}.e \n"
target+="wget #{ARGV[0]}/#{base}"+"_genomic.gff.gz >>#{base}.o 2>>#{base}.e \n echo done"
puts target
`#{target}`
