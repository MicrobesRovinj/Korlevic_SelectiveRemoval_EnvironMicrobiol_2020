#################################################################################################################
# plot_community_barplot_domain.R
# 
# A script to plot the community structure of each sample.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v132.wang.tax.summary
#               data/raw/metadata.csv
# Produces: results/figures/community_barplot_domain.jpg
#
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

plot <- filter(community, taxlevel==2 | str_detect(taxon, "Chloroplast$")) %>%
  filter_at(6:ncol(.), any_vars(. >= 1)) %>%
  mutate_at(5:ncol(.), funs(case_when(taxon=="Cyanobacteria" ~ . - .[taxon=="Chloroplast"],
                                      TRUE ~ .))) %>%
  mutate(taxon=str_replace(taxon, "unknown_unclassified", "No Relative")) %>%
  filter_at(6:ncol(.), any_vars(. >= 1)) %>%
  bind_rows(summarise_all(., funs(ifelse(is.numeric(.), 100-sum(.), paste("Other"))))) %>%
  rename_at(names(metadata), ~unname(metadata)) %>%
  arrange(-row_number())

plot <- plot[c(2, 1, 3:nrow(plot)), ]

color <- read_tsv("data/raw/group_colors.csv") %>%
  deframe()

names <- parse(text=case_when(plot$taxon=="Chloroplast" ~ plot$taxon,
                              plot$taxon=="Other" ~ plot$taxon,
                              plot$taxon=="No Relative" ~ "No~Relative",
                              plot$taxon=="Other Proteobacteria" ~ "Other~italic(Proteobacteria)",
                              plot$taxon=="Bacteria_unclassified" ~ "unclassified~italic(Bacteria)",
                              TRUE ~ paste0("italic(", plot$taxon, ")")))

gather(plot, key="sample", value="abundance", 6:(ncol(plot))) %>%
  mutate(taxon=factor(taxon, levels=unique(plot$taxon))) %>%
  mutate(sample=factor(sample, levels=unname(rev(metadata)))) %>%
  ggplot() +
  geom_bar(aes(x=sample, y=abundance, fill=taxon), stat="identity", colour="black", size=0.2) +
  scale_fill_manual(values=color, labels=names, guide=guide_legend(reverse=T)) + 
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

ggsave("results/figures/community_barplot.jpg", width=210, height=297, units="mm")
