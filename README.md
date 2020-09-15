## Selective DNA and Protein Isolation from Marine Macrophyte Surfaces
This is the repository for the manuscript "Selective DNA and Protein Isolation from Marine Macrophyte Surfaces" written by Marino Korlević, Marsej Markovski, 
Zihao Zhao, Gerhard J. Herndl and Mirjana Najdek. Raw 16S rRNA sequencing data with the exception of the negative control has been deposited in the European Nucleotide 
Archive (ENA) at EMBL-EBI under accession numbers SAMEA6786270, SAMEA6648792 – SAMEA6648794, SAMEA6648809 – SAMEA6648811. Negative control files are part of this repository and located in data/raw/. To be able to reproduce the 
results the mothur compatible [SILVA](http://www.arb-silva.de) reference file (Release 138, available under a [CC BY 4.0 license](https://www.arb-silva.de/silva-license-information/)) must be 
created according to the instruction given on [the mothur blog](https://mothur.org/blog/2020/SILVA-v138-reference-files/) and in the Makefile. In addition, a more detailed classification of chloroplast sequences was performed using the RDP ([Ribosomal Database Project](http://rdp.cme.msu.edu/), available under a [CC BY-SA 3.0 license](https://rdp.cme.msu.edu/misc/citation.jsp;jsessionid=B9944BE326AC81EAE4FDFE486D04FEA9.10.0.0.9)) training set (version 16) reference files [adapted for mothur](https://mothur.org/wiki/rdp_reference_files/).

Metagenomic analysis was performed separately and results required by this study are located in results/metagenomics/. Raw metagenomic sequencing data has been deposited in the European Nucleotide Archive (ENA) at EMBL-EBI under accession numbers SAMEA6648795, SAMEA6648797, SAMEA6648809 and SAMEA6648811. Metaproteomic raw data is located in results/metaproteomics/. This README file contains an overview of the repository structure, information on software dependencies and instructions how to reproduce and rerun the analysis.

### Overview

	project
	|- README                       # the top level description of content (this doc)
	|- LICENSE                      # the license for this project
	|
	|- submission/                  # files necessary for manuscript or supplementary information rendering, e.g executable Rmarkdown
	| |- manuscript.Rmd             # executable Rmarkdown for the manuscript of this study
	| |- manuscript.md              # Markdown (GitHub) version of the manuscript.Rmd file
	| |- manuscript.tex             # TeX version of manuscript.Rmd file
	| |- manuscript.pdf             # PDF version of manuscript.Rmd file
	| |- manuscript.aux             # auxiliary file of the manuscript.tex file, used for cross-referencing
	| |- header.tex                 # LaTeX header file to format the PDF version of manuscript
	| |- supplementary.Rmd          # executable Rmarkdown for the supplementary information of this study
	| |- supplementary.md           # Markdown (GitHub) version of the supplementary.Rmd file
	| |- supplementary.tex          # TeX version of supplementary.Rmd file
	| |- supplementary.pdf          # PDF version of supplementary.Rmd file
	| |- supplementary.aux          # auxiliary file of the supplementary.tex file, used for cross-referencing
	| |- header_supplementary.tex   # LaTeX header file to format the PDF version of supplementary information
	| |- references.bib             # BibTeX formatted references
	| +- citation_style.csl         # csl file to format references
	|
	|- data                         # raw and primary data, are not changed once created
	| |- references/                # reference files to be used in analysis
	| |- raw/                       # raw data, will not be altered
	| |- mothur/                    # mothur processed data
	|
	|- code/                        # any programmatic code
	|
	|- results                      # output from workflows and analyses
	| |- figures/                   # graphs designated for manuscript or supplementary information figures
	| |- images/                    # images designated for manuscript or supplementary information figures
	| |     
	| |- metagenomics               # folders containing files produced in the metagenomic analysis
	| | |- cog/                     # files containg data on coding sequences COG functional categories
	| | |- statistics/              # metagenomic statistical data
	| | +- taxonomy/                # files containg taxonomic classification of metagenomic coding sequences
	| |
	| +- metaproteomics/            # files containing data produced in the metaprotemic analysis
	|
	|-.gitignore                    # gitinore file for this study
	|-.Rprofile                     # Rprofile file containing information on which R libraries to load,
	|                               # rendering options for knitr and Rmarkdown, functions etc.
	+- Makefile                     # executable Makefile for this study

### How to regenerate this repository

#### Dependencies
* GNU Bash (v. 4.2.46(2))
* GNU Make (v. 3.82); should be located in the user's PATH
* mothur (v. 1.43.0)
* R (v. 3.6.0); should be located in the user's PATH
* R packages:
  * `stats (v. 3.6.0)`
  * `knitr (v. 1.25)`
  * `rmarkdown (v. 1.16)`
  * `tinytex (v. 0.16)`
  * `tidyverse (v. 1.2.1)`
  * `RColorBrewer (v. 1.1.2)`
  * `kableExtra (v. 1.1.0)`
  * `grid (v. 3.6.0)`
  * `matrixStats (v 0.56.0)`
  * `cowplot (v. 1.0.0)`
* The analysis supposes the use of 16 processor cores.

#### Running analysis
Before running the analysis be sure to generate the mothur compatible SILVA reference file and indicate in the Makefile its location. The manuscript and supplementary information can be regenerated on a Linux computer by running the following commands:
```
git clone https://github.com/mkorlevic/Korlevic_SelectiveRemoval_EnvironMicrobiol_2020.git
cd Korlevic_SelectiveRemoval_EnvironMicrobiol_2020/
make submission/manuscript.pdf
```
If something goes wrong and the analysis needs to be restarted run the following command from the project home directory before rerunning the analysis:
```
make clean
```
