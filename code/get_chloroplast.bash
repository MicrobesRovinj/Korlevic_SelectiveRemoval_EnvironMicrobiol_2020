#!/bin/bash

code/sina/sina --fasta-write-dots -i data/mothur/chloroplast.pick.ng.fasta -r data/references/SILVA_132_SSURef_NR99_13_12_17_opt.arb -o data/mothur/chloroplast.pick.ng.sina.fasta

tail -n +2 data/mothur/chloroplast.pick.count_table > data/mothur/chloroplast.pick.no_header.count_table

join -t $'\t' -1 1 -2 1 <(awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' < data/mothur/chloroplast.pick.ng.sina.fasta | cut -c 2- | sort -t $'\t' -k1,1) <(sort -t $'\t' -k1,1 data/mothur/chloroplast.pick.no_header.count_table) | awk -F '\t' '{printf(">%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n%s\n",$1,$4,$5,$6,$7,$8,$9,$10,$2);}' > data/mothur/chloroplast.pick.ng.sina.merged.fasta
