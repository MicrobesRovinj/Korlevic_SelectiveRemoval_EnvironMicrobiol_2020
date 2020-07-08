#################################################################################################################
# plot_chloroplast.R
# 
# A script to plot the abundance and taxonomy of chloroplast sequences of each sample.
# Dependencies: data/mothur/chloroplast.pds.wang.tax.summary
#               data/raw/metadata.csv
# Produces: results/figures/chloroplast.jpg
#
#################################################################################################################

# Loading input data containing sequence abundances and subsequent input data customization
community <- read_tsv("data/mothur/chloroplast.pds.wang.tax.summary") %>%
  filter(taxon!="Root")

# Calculating relative abundaces
community <- group_by(community, taxlevel) %>%
  mutate_at(5:ncol(.), list(~. / sum(.) * 100)) %>%
  ungroup()

# Selection of groups for plotting
plot <- filter(community, taxlevel==5)

# Defying group colors
color <- c("Bacteria_unclassified"="goldenrod1",
           "Bacillariophyta"="darkolivegreen3",
           "Chlorarachniophyceae"="yellow",
           "Chlorophyta"="aquamarine4",
           "Chloroplast_unclassified"="green",
           "Cryptomonadaceae"="orange3",
           "Streptophyta"="violet",
           "Cyanobacteria_unclassified"="forestgreen",
           "Cyanobacteria/Chloroplast_unclassified"="lightgreen")

# Generation of italic names for groups
names <- parse(text=case_when(plot$taxon=="Bacteria_unclassified" ~ "italic('Bacteria')~plain('(No Relative)')",
                              plot$taxon=="Chloroplast_unclassified" ~ "plain('Chloroplast')~plain('(No Relative)')",
                              plot$taxon=="Cyanobacteria_unclassified" ~ "italic('Cyanobacteria')~plain('(No Relative)')",
                              plot$taxon=="Cyanobacteria/Chloroplast_unclassified" ~ "italic('Cyanobacteria')*plain('/Chloroplast')~'(No Relative)'",
                              TRUE ~ paste0("plain('", plot$taxon, "')")))

# Tidying the sequence abundance data
plot <- gather(plot, key="Group", value="abundance", 6:(ncol(plot)))

# Loading metadata
metadata <- read_tsv("data/raw/metadata.csv")

# Joining sequence abundance data and metadata
Sys.setlocale(locale="en_GB.utf8")
plot <- inner_join(metadata, plot, by=c("ID"="Group")) %>%
  mutate(taxon=factor(taxon, levels=unique(plot$taxon)))

# Plot generation
ggplot(plot) +
  geom_bar(aes(x=ID, y=abundance, fill=taxon), stat="identity", colour="black", size=0.3) +
  scale_fill_manual(values=color, labels=names) + 
  labs(x=NULL, y="%") +
  scale_y_continuous(expand=c(0, 0), breaks=seq(0, 100, by=10)) +
  theme(text=element_text(family="Times"), line=element_line(color="black"),
        panel.grid=element_blank(), axis.line.y=element_line(),
        axis.ticks.x=element_blank(), axis.ticks.y.left=element_line(),
        axis.text.y=element_text(size=14, color="black"), axis.text.x=element_text(size=14, color="black", face="italic"),
        axis.title.y=element_text(size=18, color="black"), panel.background=element_blank(),
        legend.title=element_blank(), legend.text=element_text(size=14),
        legend.spacing.x=unit(0.2, "cm"), legend.justification=c("bottom"),
        legend.box.margin=margin(0, 0, 0,-20), legend.text.align=0,
        legend.key.size=unit(0.9, "cm"), plot.margin=unit(c(5.5, 5.5, 82.5, 5.5), "pt")) +
  scale_x_discrete(labels=str_wrap(c("Cymodocea nodosa",
                                     "Cymodocea nodosa",
                                     "Caulerpa cylindracea",
                                     "Caulerpa cylindracea",
                                     "Cymodocea nodosa",
                                     "Caulerpa cylindracea",
                                     "Caulerpa cylindracea"), width=10)) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=0.55, xmax=1.45, ymin=-9, ymax=-9) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=1.55, xmax=3.45, ymin=-9, ymax=-9) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=3.55, xmax=4.45, ymin=-9, ymax=-9) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=4.55, xmax=6.45, ymin=-9, ymax=-9) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=6.55, xmax=7.45, ymin=-9, ymax=-9) +
  annotation_custom(textGrob(str_wrap("Saline", width=10), gp=gpar(fontsize=14, fontface="bold", fontfamily="Times")), xmin=0.55, xmax=1.45, ymin=-13, ymax=-13) +
  annotation_custom(textGrob(str_wrap("Funtana (Mixed)", width=10), gp=gpar(fontsize=14, fontface="bold", fontfamily="Times")), xmin=1.55, xmax=3.45, ymin=-13, ymax=-13) +
  annotation_custom(textGrob(str_wrap("Funtana (Monospecific)", width=10), gp=gpar(fontsize=14, fontface="bold", fontfamily="Times")), xmin=3.55, xmax=4.45, ymin=-13, ymax=-13) +
  annotation_custom(textGrob(str_wrap("Funtana (Mixed)", width=10), gp=gpar(fontsize=14, fontface="bold", fontfamily="Times")), xmin=4.55, xmax=6.45, ymin=-13, ymax=-13) +
  annotation_custom(textGrob(str_wrap("Funtana (Monospecific)", width=10), gp=gpar(fontsize=14, fontface="bold", fontfamily="Times")), xmin=6.55, xmax=7.45, ymin=-13, ymax=-13) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=0.55, xmax=4.45, ymin=-19, ymax=-19) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=4.55, xmax=7.45, ymin=-19, ymax=-19) +
  annotation_custom(textGrob("4 December 2017", gp=gpar(fontsize=14, fontface="bold", fontfamily="Times")), xmin=0.55, xmax=4.45, ymin=-21, ymax=-21) +
  annotation_custom(textGrob("19 June 2018", gp=gpar(fontsize=14, fontface="bold", fontfamily="Times")), xmin=4.55, xmax=7.45, ymin=-21, ymax=-21) +
  coord_cartesian(clip="off")

# Plot saving
ggsave("results/figures/chloroplast.jpg", width=297, height=210, units="mm")