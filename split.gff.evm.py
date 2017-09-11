#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import sys
if len(sys.argv) < 4:
	print "python ",sys.argv[0]," <prefix of outdir> <genemarkes.gff> <august.gff> <...gff>, at least two gff file\n"
	sys.exit()

import re
import os
#from  collections  import defaultdict
#genes = defaultdict(defaultdict)
genes = {}
prefix = sys.argv[1]
for gff in sys.argv[2:]:
	print '#start read ',gff
	file = open(gff,"r")
	for line in file.readlines():
		if not re.search(r'mRNA',line): continue # if in one line
		arr = line.split("\t")
		genes.setdefault(arr[0],{}) #defined defalut duowei dict
		genes[arr[0]].setdefault(arr[1],"") #defined defalut duowei dict

		genes[arr[0]][arr[1]] += line
		
		line = line.strip()
		#print 'this line is:',line
#	line 13 end
	print '#end read ',gff,'\n'
	
#line 10 end

dir = os.path.dirname(prefix)
if dir != "" and not os.path.exists(dir): os.makedirs(dir) 
for scf in genes:
	out = prefix + '.' + scf + '.gff'
	the_scaf_file = open(out,"w+")
	the_scf = ''
	print '#open file ' + out
	for method in genes[scf]:
		the_scf += genes[scf][method]

	#print 'for scaf:',scf,"\nis",the_scf,"end\n"
	the_scaf_file.write(the_scf)
	the_scaf_file.close()
	print '#close file ' + out



