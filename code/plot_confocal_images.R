#################################################################################################################
# plot_confocal_images.R
# 
# A script to arrange and plot confocal images.
# Dependencies: results/images/
# Produces: results/images/confocal_images.jpg
#
#################################################################################################################

library(gridExtra)
library(magick)

files <-c(scy_n_dec="14_03_2018_1_SCy-N-02a_ch00.tif",
           scy_dna_dec="16_03_2018_1-SCy-dna1-02a_ch00.tif",
           scy_prot_dec="14_03_2018_1_SCy-prot1-01a_ch00.tif",
           fcym_n_dec="15_03_2018_1-FCyM-N-03a_ch00.tif",
           fcym_dna_dec="15_03_2018_1-FCyM-dna1-ponovo-03a_ch00.tif",
           fcym_prot_dec="15_03_2018_1-FCyM-prot1-02a_ch00.tif",
           fcam_n_dec="14_03_2018_01_FCaM-N-02a_ch00.tif",
           fcam_dna_dec="14_03_2018_01_FCaM-dna1-03a_ch00.tif",
           fcam_prot_dec="16_03_2018_01_FCaM-prot1-02a_ch00.tif",
           fca_n_dec="15_03_2018_01-FCa-N-01a_ch00.tif",
           fca_dna_dec="16_03_2018_01_FCa-dna1-01a_ch00.tif",
           fca_prot_dec="15_03_2018_01-FCa-prot1-02a_ch00.tif",
           fcym_n_jun="30_08_2018_7mj-FCyM-N-2-03a_ch00.tif",
           fcym_dna_jun="29_08_2018_FCyM-dna-1-01a_ch00.tif",
           fcym_prot_jun="29_08_2018_FCyM-prot-1-0a_ch00.tif",
           fcam_n_jun="29_08_2018_FCaM-N-02a_ch00.tif",
           fcam_dna_jun="29_08_2018_FCaM-dna-01a_ch00.tif",
           fcam_prot_jun="31_08_2018_7mj-FCaM-prot-03a_ch00.tif",
           fca_n_jun="31_08_2018_7mj-FCa-N-01a_ch00.tif",
           fca_dna_jun="31_08_2018_7mj-FCa-dna-01a_ch00.tif",
           fca_dna_jun="31_08_2018_7mj-FCa-prot-01a_ch00.tif")

images <- lapply(unname(files), function(x) image_read(paste0("results/images/", x)))

grid.arrange(rasterGrob(images[[1]]), rasterGrob(images[[2]]), rasterGrob(images[[3]]),
             rasterGrob(images[[4]]), rasterGrob(images[[5]]), rasterGrob(images[[6]]),
             rasterGrob(images[[7]]), rasterGrob(images[[8]]), rasterGrob(images[[9]]),
             rasterGrob(images[[10]]), rasterGrob(images[[11]]), rasterGrob(images[[12]]),
             rasterGrob(images[[13]]), rasterGrob(images[[14]]), rasterGrob(images[[15]]),
             rasterGrob(images[[16]]), rasterGrob(images[[17]]), rasterGrob(images[[18]]),
             rasterGrob(images[[19]]), rasterGrob(images[[20]]), rasterGrob(images[[21]]),
             nrow=7, ncol=3)

ggsave("results/images/", width=210, height=297, units="mm")

# Loading metadata of each sample and selection of desired information of each sample
metadata <- read_tsv("data/raw/metadata.csv") %>%
  filter(ID %in% colnames(community[, 6:ncol(community)])) %>%
  select(ID, label) %>%
  deframe()



# Plot generation
gather(plot, key="sample", value="abundance", 6:(ncol(plot))) %>%
  mutate(taxon=factor(taxon, levels=unique(plot$taxon))) %>%
  mutate(sample=factor(sample, levels=metadata)) %>%
  ggplot() +
  geom_bar(aes(x=sample, y=abundance, fill=taxon), stat="identity", colour="black", size=0.3) +
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
        legend.box.margin=margin(0,0, 0,-20), legend.text.align=0,
        legend.key.size=unit(0.9, "cm"), plot.margin = unit(c(5.5, 5.5, 82.5, 5.5), "pt")) +
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
  annotation_custom(textGrob(str_wrap("Saline", width=10), gp=gpar(fontsize=14, fontface="bold")), xmin=0.55, xmax=1.45, ymin=-13, ymax=-13) +
  annotation_custom(textGrob(str_wrap("Funtana-Invaded", width=10), gp=gpar(fontsize=14, fontface="bold")), xmin=1.55, xmax=3.45, ymin=-13, ymax=-13) +
  annotation_custom(textGrob(str_wrap("Funtana-Noninvaded", width=10), gp=gpar(fontsize=14, fontface="bold")), xmin=3.55, xmax=4.45, ymin=-13, ymax=-13) +
  annotation_custom(textGrob(str_wrap("Funtana-Invaded", width=10), gp=gpar(fontsize=14, fontface="bold")), xmin=4.55, xmax=6.45, ymin=-13, ymax=-13) +
  annotation_custom(textGrob(str_wrap("Funtana-Noninvaded", width=10), gp=gpar(fontsize=14, fontface="bold")), xmin=6.55, xmax=7.45, ymin=-13, ymax=-13) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=0.55, xmax=4.45, ymin=-19, ymax=-19) +
  annotation_custom(linesGrob(gp=gpar(lwd=2)), xmin=4.55, xmax=7.45, ymin=-19, ymax=-19) +
  annotation_custom(textGrob("4 December 2017", gp=gpar(fontsize=14, fontface="bold")), xmin=0.55, xmax=4.45, ymin=-21, ymax=-21) +
  annotation_custom(textGrob("19 June 2018", gp=gpar(fontsize=14, fontface="bold")), xmin=4.55, xmax=7.45, ymin=-21, ymax=-21) +
  coord_cartesian(clip="off")
 

# Plot saving

