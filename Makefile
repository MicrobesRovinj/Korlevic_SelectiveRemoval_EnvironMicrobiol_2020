MOTHUR = code/mothur/mothur
RAW = data/raw
MOTH = data/mothur
REFS = data/references
BASIC_STEM = data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster
FIGS = results/figures
TABLES = results/tables
PROC = data/process
FINAL = submission

# Obtained the Linux version of mothur (v1.42.1) from the mothur GitHub repository
$(MOTHUR) :
	wget --no-check-certificate https://github.com/mothur/mothur/releases/download/v1.42.1/Mothur.linux_64.zip
	unzip Mothur.linux_64.zip
	mv mothur code/
	rm Mothur.linux_64.zip
	rm -rf __MACOSX

#########################################################################################
#
# Part 1: Create the reference files
#
# 	We will need several reference files to complete the analyses including the
# SILVA reference alignment and taxonomy. As we are analyzing both Bacteria and
# Archaea we need to optimize the procedure described on the mothur blog
# (http://blog.mothur.org/2018/01/10/SILVA-v132-reference-files/).
#
#########################################################################################

$(REFS)/silva.nr_v132.pcr%align\
$(REFS)/silva.nr_v132.pcr.unique%align\
$(REFS)/silva.nr_v132%tax : ~/references/data/references/silva.nr_v132.pcr.align\
                            ~/references/data/references/silva.nr_v132.pcr.unique.align\
                            ~/references/data/references/silva.nr_v132.tax
	cp ~/references/data/references/silva.nr_v132.pcr.align $(REFS)/
	cp ~/references/data/references/silva.nr_v132.pcr.unique.align $(REFS)/
	cp ~/references/data/references/silva.nr_v132.tax $(REFS)/

#########################################################################################
#
# Part 2: Run data through mothur and get the sequencing error
#
# 	Process fastq data through the generation of files that will be used in the
# overall analysis.
#
#########################################################################################
$(RAW)/raw.files : $(RAW)/metadata.csv
	cut -f 1,6,7 data/raw/metadata.csv | tail -n +2 > $(RAW)/raw.files

$(RAW)/*.fastq : $(RAW)/raw.files\
                 ~/raw/together/*.fastq
	(cut -f 2 $(RAW)/raw.files; cut -f 3 $(RAW)/raw.files) | cat > $(RAW)/names_file.txt
	xargs -I % --arg-file=$(RAW)/names_file.txt cp ~/raw/together/% -t $(RAW)/	

# Here we go from the raw fastq files and the files file to generate a fasta,
# taxonomy, and count_table file that has had the chimeras removed as well as
# any non bacterial or archeal sequences.
# The raw data (.fastq files) should be locateted in data/raw/

# Add a primer.oligos file containing the sequences of the gene speciic primers
$(MOTH)/raw.trim.contigs%fasta\
$(MOTH)/raw.trim.contigs.good.unique%fasta\
$(MOTH)/raw.trim.contigs.good%count_table\
$(MOTH)/raw.trim.contigs.good%unique.align\
$(MOTH)/raw.trim.contigs.good%unique.good.align\
$(MOTH)/raw.trim.contigs.good.good%count_table\
$(BASIC_STEM).pick%fasta\
$(BASIC_STEM).denovo.vsearch.pick%count_table\
$(BASIC_STEM).pick.pick%fasta\
$(BASIC_STEM).denovo.vsearch.pick.pick%count_table\
$(BASIC_STEM).pick.nr_v132.wang.pick%taxonomy\
$(BASIC_STEM).pick.nr_v132.wang.tax%summary : code/get_good_seqs.batch\
                                              $(RAW)/raw.files\
                                              $(RAW)/primer.oligos\
                                              $(RAW)/*.fastq\
                                              $(REFS)/silva.nr_v132.pcr.align\
                                              $(REFS)/silva.nr_v132.pcr.unique.align\
                                              $(REFS)/silva.nr_v132.tax\
                                              $(MOTHUR)
	$(MOTHUR) code/get_good_seqs.batch
	rm data/mothur/*.map

# Create a summary.txt file to check that all went alright throughout the code/get_good_seqs.batch
data/summary.txt : $(REFS)/silva.nr_v132.pcr.align\
                   $(REFS)/silva.nr_v132.pcr.unique.align\
                   $(MOTH)/raw.trim.contigs.fasta\
                   $(MOTH)/raw.trim.contigs.good.unique.fasta\
                   $(MOTH)/raw.trim.contigs.good.count_table\
                   $(MOTH)/raw.trim.contigs.good.unique.align\
                   $(MOTH)/raw.trim.contigs.good.unique.good.align\
                   $(MOTH)/raw.trim.contigs.good.good.count_table\
                   $(BASIC_STEM).pick.fasta\
                   $(BASIC_STEM).denovo.vsearch.pick.count_table\
                   $(BASIC_STEM).pick.pick.fasta\
                   $(BASIC_STEM).denovo.vsearch.pick.pick.count_table\
                   $(MOTHUR)
	$(MOTHUR) code/get_summary.batch

# Here we go from the good sequences and generate a shared file and a
# cons.taxonomy file based on OTU data.

# Edit code/get_shared_otus.batch to include the proper root name of your files file.
# Edit code/get_shared_otus.batch to include the proper group names to remove.

$(BASIC_STEM).pick.pick.pick.opti_mcc%shared\
$(BASIC_STEM).pick.pick.pick.opti_mcc.unique_list.0.03.cons%taxonomy : code/get_shared_otus.batch\
                                                                       $(BASIC_STEM).pick.pick.fasta\
                                                                       $(BASIC_STEM).denovo.vsearch.pick.pick.count_table\
                                                                       $(BASIC_STEM).pick.nr_v132.wang.pick.taxonomy\
                                                                       $(MOTHUR)
	$(MOTHUR) code/get_shared_otus.batch
	rm $(BASIC_STEM).denovo.vsearch.pick.pick.pick.count_table
	rm $(BASIC_STEM).pick.pick.pick.fasta
	rm $(BASIC_STEM).pick.nr_v132.wang.pick.pick.taxonomy

# Now we want to get the sequencing error as seen in the mock community samples.

# Edit code/get_error.batch to include the proper group names for your mocks.

$(BASIC_STEM).pick.pick.pick.error.summary : code/get_error.batch\
                                             $(BASIC_STEM).pick.pick.fasta\
                                             $(BASIC_STEM).denovo.vsearch.pick.pick.count_table\
                                             ~/atcc/ATCC_MSA-1002_515F-806R.fasta\
                                             $(MOTHUR)
	cp ~/atcc/ATCC_MSA-1002_515F-806R.fasta $(REFS)/atcc_v4.fasta
	$(MOTHUR) code/get_error.batch

#########################################################################################
#
# Part 3: Figure and table generation
#
# 	Run scripts to generate figures and tables
#
#########################################################################################

# Generate a community composition barplot
$(FIGS)/community_barplot.jpg : code/plot_community_barplot.R\
                                $(BASIC_STEM).pick.nr_v132.wang.tax.summary\
                                $(RAW)/group_colors.csv
	R -e "source('code/plot_community_barplot.R')"

# Generate rarefaction data
$(BASIC_STEM).pick.pick.pick.opti_mcc.groups.rarefaction : $(BASIC_STEM).pick.pick.pick.opti_mcc.shared\
                                                           code/get_rarefaction_data.batch\
                                                           $(MOTHUR)
	$(MOTHUR) code/get_rarefaction_data.batch

# Construct a rarefaction plot
$(FIGS)/rarefaction.jpg : code/plot_rarefaction.R\
                          $(BASIC_STEM).pick.pick.pick.opti_mcc.groups.rarefaction
	R -e "source('code/plot_rarefaction.R')"

# Generate data to plot PCoA ordination
$(BASIC_STEM).pick.pick.pick.opti_mcc.braycurtis.0.03.lt.ave.pcoa%axes\
$(BASIC_STEM).pick.pick.pick.opti_mcc.braycurtis.0.03.lt.ave.pcoa%loadings : code/get_pcoa_data.batch\
                                                                             $(BASIC_STEM).pick.pick.pick.opti_mcc.shared\
                                                                             $(MOTHUR)
	$(MOTHUR) code/get_pcoa_data.batch

# Construct a PCoA plot
$(FIGS)/pcoa_figure.jpg : code/plot_pcoa.R\
                          $(BASIC_STEM).pick.pick.pick.opti_mcc.braycurtis.0.03.lt.ave.pcoa.axes\
                          $(BASIC_STEM).pick.pick.pick.opti_mcc.braycurtis.0.03.lt.ave.pcoa.loadings\
                          $(RAW)/metadata.csv
	R -e "source('code/plot_pcoa.R')"

#########################################################################################
#
# Part 4: Combaine all together
#
# 	Render the manuscript
#
#########################################################################################

.PHONY: all
all : data/summary.txt\
      $(FIGS)/community_barplot.jpg\
      $(BASIC_STEM).pick.pick.pick.error.summary\
      $(FIGS)/pcoa_figure.jpg\
      $(FIGS)/rarefaction.jpg

# Cleaning
.PHONY: clean
clean :
	rm -f my_job.qsub.* || true
	rm -f $(REFS)/* || true
	rm -f $(MOTH)/* || true
	rm -f data/summary.txt || true
	rm -f $(RAW)/*.fastq || true
	rm -f $(RAW)/names_file.txt || true
	rm -f $(RAW)/raw.files || true
	rm -rf code/mothur/ || true
	rm -f $(FIGS)/* || true
	rm -f mothur*logfile || true
