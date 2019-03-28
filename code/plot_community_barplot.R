#################################################################################################################
# plot_community_barplot.R
# 
# A script to plot the community structure of each sample.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v132.wang.tax.summary
# Produces: results/figures/community_barplot.jpg
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

plot <- filter(community, !str_detect(taxon, "_unclassified$")) %>%
  filter(!str_detect(taxon, "_ph$")) %>%
  filter(!str_detect(taxon, "_cl$")) %>%
  filter(!str_detect(taxon, "_or$")) %>%
  filter(!str_detect(taxon, "_fa$")) %>%
  filter(!str_detect(taxon, "_ge$")) %>%
  filter(taxlevel==2 | str_detect(taxon, "proteobacteria$")
                     | str_detect(taxon, "Chloroplast")
                     | str_detect(taxon, "unknown")) %>%
  filter_at(6:ncol(.), any_vars(. >= 1)) %>%
  mutate_at(5:ncol(.), funs(case_when(taxon=="Cyanobacteria" ~ . - .[taxon=="Chloroplast"],
                                      taxon=="Proteobacteria" ~ . - sum(.[str_detect(taxon, "proteobacteria$")]),
                                      TRUE ~ .))) %>%
  mutate(taxon=str_replace(taxon, "Proteobacteria", "Other Proteobacteria")) %>%
  mutate(taxon=str_replace(taxon, "unknown", "No Relative")) %>%
  filter_at(6:ncol(.), any_vars(. >= 1)) %>%
  bind_rows(summarise_all(., funs(ifelse(is.numeric(.), 100-sum(.), paste("Other")))))

color <- c("Actinobacteria"="#E31A1C",
           "Bacteroidetes"="#1F78B4",
           "Chloroflexi"="#FB9A99",
           "Cyanobacteria"="#B2DF8A",
           "Chloroplast"="#33A02C",
           "Firmicutes"="#6A3D9A",
           "Planctomycetes"="#FDBF6F",
           "Alphaproteobacteria"="#A6CEE3",
           "Deltaproteobacteria"="#B15928",
           "Gammaproteobacteria"="#FFFF99",
           "Other Proteobacteria"="#CCCFFF",
           "Verrucomicrobia"="#FF7F00",
           "Other"="#FFFFFF",
           "No Relative"="#CCCCCC")

names <- parse(text=case_when(plot$taxon=="Chloroplast" ~ plot$taxon,
                              plot$taxon=="Other" ~ plot$taxon,
                              plot$taxon=="No Relative" ~ "No~Relative",
                              plot$taxon=="Other Proteobacteria" ~ "Other~italic(Proteobacteria)",
                              TRUE ~ paste0("italic(", plot$taxon, ")")))

gather(plot, key="sample", value="abundance", 6:(ncol(plot))) %>%
  mutate(taxon=factor(taxon, levels=names(color))) %>%
  ggplot() +
  geom_bar(aes(x=sample, y=abundance, fill=taxon), stat="identity", colour="black", size=0.2) +
  scale_fill_manual(values=color, labels=names) + 
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

ggsave("results/figures/community_barplot.jpg")
