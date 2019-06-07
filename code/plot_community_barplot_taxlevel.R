#################################################################################################################
# plot_community_barplot_taxlevel.R
# 
# A script to plot the community structure of each sample at every taxonomic level (Domain-Genus).
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v132.wang.tax.summary
# Produces: results/figures/community_barplot_domain.jpg
#           results/figures/community_barplot_phylum.jpg
#           results/figures/community_barplot_class.jpg
#           results/figures/community_barplot_order.jpg
#           results/figures/community_barplot_family.jpg
#           results/figures/community_barplot_genus.jpg
#################################################################################################################

library(tidyverse)

community <- read_tsv("data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v132.wang.tax.summary") %>%
  filter(!str_detect(taxon, "^Eukaryota")) %>%
  filter(taxon!="Root") %>%
  filter(!str_detect(taxon, "^Mitochondria")) %>%
  group_by(taxlevel) %>%
  mutate_at(5:ncol(.), funs(. / sum(.) * 100)) %>%
  ungroup()

metadata <- read_tsv("data/raw/metadata.csv") %>%
  filter(ID %in% colnames(community[, 6:ncol(community)])) %>%
  select(ID, label) %>%
  deframe()

taxlevel <- c("domain", "phylum", "class", "order", "family", "genus")

for (i in seq(1:6)) {
plot <- filter(community, taxlevel==i) %>%
  filter_at(6:ncol(.), any_vars(. >= 2)) %>%
  mutate(taxon=str_replace_all(taxon, c("unknown_unclassified"="No Relative", "unknown"="No Relative"))) %>%
  filter_at(6:ncol(.), any_vars(. >= 2)) %>%
  bind_rows(summarise_all(., funs(ifelse(is.numeric(.), 100-sum(.), paste("Other"))))) %>%
  rename_at(names(metadata), ~unname(metadata)) %>%
  arrange(-row_number())

color <- read_tsv("data/raw/group_colors.csv") %>%
  deframe()

gather(plot, key="sample", value="abundance", 6:(ncol(plot))) %>%
  mutate(taxon=factor(taxon, levels=unique(plot$taxon))) %>%
  mutate(sample=factor(sample, levels=unname(rev(metadata)))) %>%
  ggplot() +
  geom_bar(aes(x=sample, y=abundance, fill=taxon), stat="identity", colour="black", size=0.2) +
  scale_fill_manual(values=color, labels=unique(plot$taxon), guide=guide_legend(reverse=T, ncol=1)) + 
  labs(x=NULL, y="%") +
  scale_y_continuous(expand=c(0, 0), breaks=seq(0, 100, by=10)) +
  coord_flip() +
  theme(panel.grid=element_blank(), axis.line.x=element_line(),
        axis.ticks.y=element_blank(), axis.ticks.x=element_line(color="black"),
        axis.text.x=element_text(color="black", size=12), axis.text.y=element_text(color="black", size=14),
        axis.title.x=element_text(color="black", size=14), axis.title.y=element_blank(),  
        panel.background=element_blank(), legend.title=element_blank(),
        legend.text=element_text(size=12), legend.spacing.x=unit(0.2, "cm"),
        legend.key.size=unit(0.75, "cm"), legend.justification=c("bottom"),
        legend.text.align=0)

ggsave(paste0("results/figures/community_barplot_", taxlevel[i], ".jpg"), width=210, height=297, units="mm")
}
