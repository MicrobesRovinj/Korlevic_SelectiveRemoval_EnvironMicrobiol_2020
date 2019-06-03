#################################################################################################################
# plot_pcoa.R
# 
# A script to generate the PCoA figure.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.braycurtis.0.03.lt.ave.pcoa.axes
#               data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.braycurtis.0.03.lt.ave.pcoa.loadings
#               data/raw/metadata.csv
# Produces: results/figures/pcoa_figure.jpg
#
#################################################################################################################

library(tidyverse)
pcoa <- read_tsv("data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.braycurtis.0.03.lt.ave.pcoa.axes")
metadata <- read_tsv("data/raw/metadata.csv")
metadata_pcoa <- inner_join(metadata, pcoa, by=c('ID'='group'))

pcoa_loadings <- read_tsv("data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.braycurtis.0.03.lt.ave.pcoa.loadings")

ggplot(metadata_pcoa, aes(x=axis1, y=axis2)) +
  geom_point(shape=19, size=2) +
  geom_text(aes(label=label), nudge_x=0.07) +
  coord_fixed() + 
  labs(x=paste("PCoA 1 (", format(round(pcoa_loadings$loading[1], 2), nsmall=2), " %)"),
       y=paste("PCoA 2 (", format(round(pcoa_loadings$loading[2], 2), nsmall=2), " %)")) +
  theme_classic()

ggsave("results/figures/pcoa_figure.jpg", width=297, height=210, units="mm")
