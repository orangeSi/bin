#!/ifshk4/BC_PUB/biosoft/PIPE_RD/Package/Ruby/install/bin/ruby -W0

if ARGV.length <1
	puts "usage: <dir,ex:'ref/*/*gbff.gz or .gbff'>"
	exit
end

parse1="/ifshk7/BC_PS/sikaiwei/bin/get_gbk.pl"
parse2="/ifshk7/BC_PS/sikaiwei/bin/genbank_parser.pl"
myfile=File.open("./run.para.sh","w")
myfile2=File.open("./config.txt","w")
Dir[ARGV[0]].each do |e|
	puts "e is"+e
	if e =~ /.gz$/
	`gzip -d #{e}`
	e.gsub!(/.gz$/,"")
	puts "#{e}"
	end
	#command="perl #{parse1} -i #{e} -fna #{e}.seq -pep #{e}.pep -cds  #{e}.cds -cds_gff #{e}.cds.gff -o / >#{e}.e 2>#{e}.o && "
	
	command="perl #{parse2}  #{e} && "
	command+="perl /ifshk7/BC_PS/sikaiwei/piple/BAC-denovo/ref/3.check_pep_or_cds_have_zero_length.pl #{e}.cds #{e}.cds.new && "
	command+="perl /ifshk7/BC_PS/sikaiwei/piple/BAC-denovo/ref/3.check_pep_or_cds_have_zero_length.pl #{e}.pep #{e}.pep.new && "
	command+="perl /ifshk7/BC_PS/sikaiwei/piple/BAC-denovo/ref/2.title.pl #{e}.cds.new #{e}.cds.new2 && "
	command+="perl /ifshk7/BC_PS/sikaiwei/piple/BAC-denovo/ref/2.title.pl #{e}.pep.new #{e}.pep.new2 && "
	command+="cat #{e}.gff|awk -F '\\t' '{if($4!=\"\")print \$0}' >#{e}.gff.new && "
	command+="echo ok"
	myfile.puts("#{command} >#{e}.e 2>#{e}.e")
	#puts "command is #{command}"
	myfile2.puts("seq = #{e}.seq")
	myfile2.puts("pep = #{e}.pep.new2")
	myfile2.puts("cds = #{e}.cds.new2")
	myfile2.puts("gff = #{e}.gff.new")
	myfile2.puts("")


end
puts "nohup sh run.para.sh &"
puts "config is config.txt"
