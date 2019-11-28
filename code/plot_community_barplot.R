#################################################################################################################
# plot_community_barplot.R
# 
# A script to plot the community structure of each sample.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v132.wang.tax.summary
# Produces: results/figures/community_barplot.jpg
#
#################################################################################################################

# Loading input data containing sequence abundances and subsequent input data customization
community <- read_tsv("data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.nr_v132.wang.tax.summary") %>%
  filter(!str_detect(taxon, "^Eukaryota")) %>%
  filter(taxon!="Root") %>%
  filter(!str_detect(taxon, "^Mitochondria")) %>%
  select(-ATCC_1, -NC_1) %>%
  group_by(taxlevel) %>%
  mutate_at(5:ncol(.), funs(. / sum(.) * 100)) %>%
  ungroup()

# Loading metadata of each sample and selection of desired information of each sample
metadata <- read_tsv("data/raw/metadata.csv") %>%
  filter(ID %in% colnames(community[, 6:ncol(community)])) %>%
  select(ID, label) %>%
  deframe()

# Selection of groups for plotting
plot <- filter(community, taxlevel==2 | str_detect(taxon, "Chloroplast$") | str_detect(taxon, "proteobacteria$")) %>%
  filter_at(6:ncol(.), any_vars(. >= 1)) %>%
  mutate_at(5:ncol(.), funs(case_when(taxon=="Cyanobacteria" ~ . - .[taxon=="Chloroplast"], TRUE ~ .))) %>%
  filter(!str_detect(taxon, "^Proteobacteria$")) %>%
  mutate(taxon=str_replace_all(taxon, c("unknown_unclassified"="No Relative", "unknown"="No Relative"))) %>%
  filter_at(6:ncol(.), any_vars(. >= 1)) %>%
  bind_rows(summarise_all(., funs(ifelse(is.numeric(.), 100-sum(.), paste("Other"))))) %>%
  rename_at(names(metadata), ~unname(metadata)) %>%
  arrange(-row_number())

# Loading colors for each group on the plot
color <- read_tsv("data/raw/group_colors.csv") %>%
  deframe()

# Generation of italic names for groups
names <- parse(text=case_when(plot$taxon=="Chloroplast" ~ paste0("plain(\"", plot$taxon,  "\")"),
                              plot$taxon=="Other" ~ paste0("plain(\"", plot$taxon, "\")"),
                              plot$taxon=="No Relative" ~ paste0("plain(\"", plot$taxon, "\")"),
                              TRUE ~ paste0("italic(\"", plot$taxon, "\")")))

# Plot generation
gather(plot, key="sample", value="abundance", 6:(ncol(plot))) %>%
  mutate(taxon=factor(taxon, levels=unique(plot$taxon))) %>%
  mutate(sample=factor(sample, levels=metadata)) %>%
  ggplot() +
  geom_bar(aes(x=sample, y=abundance, fill=fct_rev(taxon)), stat="identity", colour="black", size=0.2) +
  scale_fill_manual(values=color, labels=rev(names), guide=guide_legend(reverse=F, ncol=1)) + 
  labs(x=NULL, y="%") +
  scale_y_continuous(expand=c(0, 0), breaks=seq(0, 100, by=10)) +
  theme(text=element_text(family="Times"), line=element_line(color="black"),
        panel.grid=element_blank(), axis.line.y=element_line(),
        axis.ticks.x=element_blank(), axis.ticks.y.left=element_line(),
        axis.text.y=element_text(size=14, color="black"), axis.text.x=element_text(size=14, color="black", face="italic"),
        axis.title.y=element_text(size=18, color="black"), panel.background=element_blank(),
        legend.title=element_blank(), legend.text=element_text(size=12),
        legend.spacing.x=unit(0.2, "cm"), legend.key.size=unit(0.75, "cm"),
        legend.justification=c("bottom"), legend.text.align=0,
        legend.position=c(1.1, -0.011), plot.margin = unit(c(5.5, 154, 60.5, 5.5), "pt")) +
  scale_x_discrete(labels=str_wrap(c("Cymodocea nodosa",
                                     "Cymodocea nodosa",
                                     "Caulerpa cylindracea",
                                     "Caulerpa cylindracea",
                                     "Cymodocea nodosa",
                                     "Caulerpa cylindracea",
                                     "Caulerpa cylindracea"), width = 10)) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=0.55, xmax=1.45, ymin=-8, ymax=-8) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=1.55, xmax=7.45, ymin=-8, ymax=-8) +
  annotation_custom(textGrob("Saline", gp=gpar(fontsize=14, fontface="bold")), xmin=0.55, xmax=1.45, ymin=-10, ymax=-10) +
  annotation_custom(textGrob("Funtana", gp=gpar(fontsize=14, fontface="bold")), xmin=1.55, xmax=7.45, ymin=-10, ymax=-10) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=0.55, xmax=4.45, ymin=-14, ymax=-14) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=4.55, xmax=7.45, ymin=-14, ymax=-14) +
  annotation_custom(textGrob("4 December 2017", gp=gpar(fontsize=14, fontface="bold")), xmin=0.55, xmax=4.45, ymin=-16, ymax=-16) +
  annotation_custom(textGrob("19 June 2018", gp=gpar(fontsize=14, fontface="bold")), xmin=4.55, xmax=7.45, ymin=-16, ymax=-16) +
  coord_cartesian(clip="off")

# Plot saving
ggsave("results/figures/community_barplot.jpg", width=297, height=210, units="mm")

