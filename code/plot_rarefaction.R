#################################################################################################################
# plot_rarefaction.R
# 
# A script to plot the rarefaction curve of each sample.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.groups.rarefaction
# Produces: results/figures/rarefaction.jpg
#
#################################################################################################################

library(tidyverse)

rarefy <- read_tsv(file="data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.groups.rarefaction") %>%
  select(-contains("lci-"), -contains("hci-")) %>%
  gather(-numsampled, key=sample, value=sobs) %>%
  mutate(sample=str_replace_all(sample, pattern="0.03-", replacement="")) %>%
  drop_na()

metadata <- read_tsv("data/raw/metadata.csv")

metadata_rarefy <- inner_join(metadata, rarefy, by=c("ID"="sample"))

ggplot(metadata_rarefy, aes(x=numsampled, y=sobs, group=ID, color=station)) +
  geom_text(data=metadata_rarefy %>% group_by(label) %>% filter(sobs==max(sobs)), aes(x=numsampled, y=sobs, label=label), 
            show.legend=FALSE) +
  geom_line() +
  labs(x="Number of Sequences", y="Number of OTUs") +
  theme_classic()

ggsave("results/figures/rarefaction.jpg", width=297, height=210, units="mm")
