#################################################################################################################
# plot_cog.R
# 
# A script to plot the relative abundance of each COG functional category in each metagenomic and
# metaproteomic sample.
# Dependencies: data/results/metagenomics/cog/45.cog_categories.tsv
#               data/results/metagenomics/cog/47.cog_categories.tsv
#               data/results/metagenomics/cog/61.cog_categories.tsv
#               data/results/metagenomics/cog/63.cog_categories.tsv  
#               data/results/metaproteomics/metaproteomics_cog.tsv
#               data/raw/cog_categories_colors.tsv
#               
# Produces: results/figures/cog.jpg
#
#################################################################################################################

##############################################
# COG functional categories in metagenomes
##############################################

# Loading COG input data and combining together
cog_45 <- read_tsv("results/metagenomics/cog/45.cog_categories.tsv", col_names = c("COG Functional Category", "45"), skip = 1)
cog_47 <- read_tsv("results/metagenomics/cog/47.cog_categories.tsv", col_names = c("COG Functional Category", "47"), skip = 1)
cog_61 <- read_tsv("results/metagenomics/cog/61.cog_categories.tsv", col_names = c("COG Functional Category", "61"), skip = 1)
cog_63 <- read_tsv("results/metagenomics/cog/63.cog_categories.tsv", col_names = c("COG Functional Category", "63"), skip = 1)

cog <- full_join(cog_45, cog_47, by = c("COG Functional Category")) %>%
  full_join(., cog_61, by = c("COG Functional Category")) %>%
  full_join(., cog_63, by = c("COG Functional Category"))

# Calculating relative abundances of each COG functional category
cog_relative <- cog %>%
  mutate(`COG Functional Category`, `COG Functional Category`=if_else(str_length(`COG Functional Category`) > 1,
         "multiple_COG", `COG Functional Category`)) %>%
  mutate(`COG Functional Category`, `COG Functional Category`=if_else(is.na(`COG Functional Category`), 
         "no_COG", `COG Functional Category`)) %>%
  replace(is.na(.), 0) %>%
  group_by(`COG Functional Category`) %>%
  summarize(`45`=sum(`45`),
            `47`=sum(`47`),
            `61`=sum(`61`),
            `63`=sum(`63`)) %>%
  mutate_at(2:ncol(.), list(~. / sum(.) * 100))

# Loading COG functional categories colors
color <- read_tsv("data/raw/cog_categories_colors.tsv") %>%
  select(-Name) %>%
  deframe()

# Loading COG functional categories names
names <- read_tsv("data/raw/cog_categories_colors.tsv") %>%
  mutate(Name, Name=paste0(Code, " – ", Name)) %>%
  mutate(Name, Name=str_replace(Name, "no_COG – ", "")) %>%
  mutate(Name, Name=str_replace(Name, "multiple_COG – ", "")) %>%
  select(-Color) %>%
  deframe()

# Calculating total number of annotated coding sequences
cds <- cog %>%
  summarise(`45`=sum(`45`, na.rm=TRUE),
            `47`=sum(`47`, na.rm=TRUE),
            `61`=sum(`61`, na.rm=TRUE),
            `63`=sum(`63`, na.rm=TRUE)) %>%
  gather(key="sample", value="abundance")

# Plot generation
p_metagenomic <- gather(cog_relative, key="sample", value="abundance", 2:(ncol(cog_relative))) %>%
  mutate(`COG Functional Category`=factor(`COG Functional Category`, levels=names(names))) %>%
  ggplot() +
  geom_bar(aes(x=sample, y=abundance, fill=`COG Functional Category`), stat="identity", colour="black", size=0.3) +
  scale_fill_manual(values=color, labels=names) + 
  geom_text(data=cds, aes(x=sample, y=101, label=format(abundance, big.mark=",")), family="Times", fontface="bold",
            size=5, angle=90, hjust=0) +
  labs(x=NULL, y="%") +
  scale_y_continuous(expand=c(0, 0), breaks=seq(0, 100, by=10)) +
  annotate("segment", x=0.4, y=-0.1, xend=0.4, yend=100.1, color="black", size=0.4) +
  theme(text=element_text(family="Times"), line=element_line(color="black"),
        panel.grid=element_blank(), axis.line.y=element_blank(),
        axis.ticks.x=element_blank(), axis.ticks.y.left=element_line(),
        axis.text.y=element_text(size=10, color="black"), axis.text.x=element_text(size=10, color="black", face="italic", angle=90, vjust=0.5),
        axis.title.y=element_text(size=12, color="black", hjust=0.495), panel.background=element_blank(),
        legend.title=element_blank(), legend.text=element_text(size=10),
        legend.spacing.x=unit(0.2, "cm"), legend.justification=c("bottom"),
        legend.box.margin=margin(0, 0, 0,-20), legend.text.align=0,
        legend.key.size=unit(0.55, "cm"), plot.margin=unit(c(71.5, 5.5, 116.5, 5.5), "pt"),
        legend.position = "none") +
  guides(fill=guide_legend(ncol=1)) +
  scale_x_discrete(labels=str_wrap(c("Cymodocea nodosa",
                                     "Caulerpa cylindracea",
                                     "Cymodocea nodosa",
                                     "Caulerpa cylindracea"), width=10)) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=0.55, xmax=1.45, ymin=-17, ymax=-17) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=1.55, xmax=2.45, ymin=-17, ymax=-17) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=2.55, xmax=3.45, ymin=-17, ymax=-17) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=3.55, xmax=4.45, ymin=-17, ymax=-17) +
  annotation_custom(textGrob(str_wrap("Funtana (Mixed)", width=10), gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=90), xmin=0.55, xmax=1.45, ymin=-29, ymax=-29) +
  annotation_custom(textGrob(str_wrap("Funtana (Monospecific)", width=10), gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=90), xmin=1.55, xmax=2.45, ymin=-29, ymax=-29) +
  annotation_custom(textGrob(str_wrap("Funtana (Mixed)", width=10), gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=90), xmin=2.55, xmax=3.45, ymin=-29, ymax=-29) +
  annotation_custom(textGrob(str_wrap("Funtana (Monospecific)", width=10), gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=90), xmin=3.55, xmax=4.45, ymin=-29, ymax=-29) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=0.55, xmax=2.45, ymin=-41, ymax=-41) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=2.55, xmax=4.45, ymin=-41, ymax=-41) +
  annotation_custom(textGrob("14 December 2017", gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=0), xmin=0.55, xmax=2.45, ymin=-45, ymax=-45) +
  annotation_custom(textGrob("19 June 2018", gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=0), xmin=2.55, xmax=4.45, ymin=-45, ymax=-45) +
  coord_cartesian(clip="off")

##############################################
# COG functional categories in metaproteomes
##############################################

# Loading metaproteomic COG input data
metap_cog <- read_tsv("results/metaproteomics/metaproteomics_cog.tsv")

# Adding category "Multiple functional categories", renaming category NA to
# "No COG category available"
metap_cog <- metap_cog %>%
  mutate(`COG Functional Category`= if_else(str_length(`COG Functional Category`) > 1,
                                            "multiple_COG", `COG Functional Category`)) %>%
  replace_na(list(`COG Functional Category` = "no_COG")) %>%
  mutate(cog_40 = if_else(is.na(`Abundance: 40: Sample`), 0, 1),
         cog_41 = if_else(is.na(`Abundance: 41: Sample`), 0, 1),
         cog_42 = if_else(is.na(`Abundance: 42: Sample`), 0, 1),
         cog_43 = if_else(is.na(`Abundance: 43: Sample`), 0, 1),
         cog_61 = if_else(is.na(`Abundance: 61: Sample`), 0, 1),
         cog_62 = if_else(is.na(`Abundance: 62: Sample`), 0, 1),
         cog_63 = if_else(is.na(`Abundance: 63: Sample`), 0, 1))

# Calculating the number of proteins in each COG functional category
metap_cog_abund <- metap_cog %>%
  group_by(`COG Functional Category`) %>%
  summarize(`40` = sum(cog_40),
            `41` = sum(cog_41),
            `42` = sum(cog_42),
            `43` = sum(cog_43),
            `61` = sum(cog_61),
            `62` = sum(cog_62),
            `63` = sum(cog_63))

# Calculating the relative contribution of proteins in each COG functional category
metap_cog_relative <- metap_cog_abund %>%
  mutate_at(2:ncol(.), list(~. / sum(.) * 100))

# Loading COG functional categories colors
color <- read_tsv("data/raw/cog_categories_colors.tsv") %>%
  select(-Name) %>%
  deframe()

# Loading COG functional categories names
names <- read_tsv("data/raw/cog_categories_colors.tsv") %>%
  mutate(Name, Name = paste0(Code, " – ", Name)) %>%
  mutate(Name, Name = str_replace(Name, "no_COG – ", "")) %>%
  mutate(Name, Name = str_replace(Name, "multiple_COG – ", "")) %>%
  select(-Color) %>%
  deframe()

# Calculating total number of identified proteins in each sample
prot <- metap_cog_abund %>%
  summarise(`40`= sum(`40`, na.rm=TRUE),
            `41`= sum(`41`, na.rm=TRUE),
            `42`= sum(`42`, na.rm=TRUE),
            `43`= sum(`43`, na.rm=TRUE),
            `61`= sum(`61`, na.rm=TRUE),
            `62`= sum(`62`, na.rm=TRUE),
            `63`= sum(`63`, na.rm=TRUE),) %>%
  gather(key = "sample", value = "abundance")

# Plot generation
p_metaproteomic <- gather(metap_cog_relative, key="sample", value="abundance", 2:(ncol(metap_cog_relative))) %>%
  mutate(`COG Functional Category`=factor(`COG Functional Category`, levels=names(names))) %>%
  ggplot() +
  geom_bar(aes(x=sample, y=abundance, fill=`COG Functional Category`), stat="identity", colour="black", size=0.3) +
  scale_fill_manual(values=color, labels=names) + 
  geom_text(data=prot, aes(x=sample, y=101, label=format(abundance, big.mark=",")), family="Times", fontface="bold",
            size=5, angle=90, hjust=0) +
  labs(x=NULL, y="%") +
  scale_y_continuous(expand=c(0, 0), breaks=seq(0, 100, by=10)) +
  theme(text=element_text(family="Times"), line=element_line(color="black"),
        panel.grid=element_blank(), axis.line.y=element_blank(),
        axis.ticks.x=element_blank(), axis.ticks.y.left=element_blank(),
        axis.text.y=element_blank(), axis.text.x=element_text(size=10, color="black", face="italic", angle=90, vjust=0.5),
        axis.title.y=element_blank(), panel.background=element_blank(),
        legend.title=element_blank(), legend.text=element_text(size=10),
        legend.spacing.x=unit(0.2, "cm"), legend.justification=c("bottom"),
        legend.box.margin=margin(0, 0, 0,-16), legend.text.align=0,
        legend.key.size=unit(0.45, "cm"), plot.margin=unit(c(71.5, 5.5, 116.5, 5.5), "pt")) +
  guides(fill=guide_legend(ncol=1)) +
  scale_x_discrete(labels=str_wrap(c("Cymodocea nodosa",
                                     "Cymodocea nodosa",
                                     "Caulerpa cylindracea",
                                     "Caulerpa cylindracea",
                                     "Cymodocea nodosa",
                                     "Caulerpa cylindracea",
                                     "Caulerpa cylindracea"), width=10)) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=0.55, xmax=1.45, ymin=-17, ymax=-17) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=1.55, xmax=3.45, ymin=-17, ymax=-17) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=3.55, xmax=4.45, ymin=-17, ymax=-17) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=4.55, xmax=6.45, ymin=-17, ymax=-17) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=6.55, xmax=7.45, ymin=-17, ymax=-17) +
  annotation_custom(textGrob(str_wrap("Saline", width=10), gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=90), xmin=0.55, xmax=1.45, ymin=-29, ymax=-29) +
  annotation_custom(textGrob(str_wrap("Funtana (Mixed)", width=10), gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=90), xmin=1.55, xmax=3.45, ymin=-29, ymax=-29) +
  annotation_custom(textGrob(str_wrap("Funtana (Monospecific)", width=10), gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=90), xmin=3.55, xmax=4.45, ymin=-29, ymax=-29) +
  annotation_custom(textGrob(str_wrap("Funtana (Mixed)", width=10), gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=90), xmin=4.55, xmax=6.45, ymin=-29, ymax=-29) +
  annotation_custom(textGrob(str_wrap("Funtana (Monospecific)", width=10), gp=gpar(fontsize=12, fontface="bold", fontfamily="Times"), rot=90), xmin=6.55, xmax=7.45, ymin=-29, ymax=-29) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=0.55, xmax=4.45, ymin=-41, ymax=-41) +
  annotation_custom(linesGrob(gp=gpar(lwd=1.2)), xmin=4.55, xmax=7.45, ymin=-41, ymax=-41) +
  annotation_custom(textGrob("4 December 2017", gp=gpar(fontsize=12, fontface="bold", fontfamily="Times")), xmin=0.55, xmax=4.45, ymin=-45, ymax=-45) +
  annotation_custom(textGrob("19 June 2018", gp=gpar(fontsize=12, fontface="bold", fontfamily="Times")), xmin=4.55, xmax=7.45, ymin=-45, ymax=-45) +
  coord_cartesian(clip="off")

# Combining plots together and saving
p <- cowplot::plot_grid(p_metagenomic, p_metaproteomic, labels = "auto", label_fontfamily = "Times",
               rel_widths = c(0.92, 2.5), label_size=30)
ggsave("results/figures/cog.jpg", p, width=297, height=210, units="mm")