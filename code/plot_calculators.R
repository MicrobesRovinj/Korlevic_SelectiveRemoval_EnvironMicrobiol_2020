#################################################################################################################
# plot_calculators.R
# 
# A script to plot richness and diversity calculators.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.groups.ave-std.summary
# Produces: results/figures/calculators.jpg
#           
#################################################################################################################

library(tidyverse)
library(gridExtra)

alpha <- read_tsv(file="data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.groups.ave-std.summary",
                 col_types=cols(group=col_character())) %>%
  filter(method=='ave')
  
metadata <- read_tsv("data/raw/metadata.csv")

meta_alpha <- inner_join(metadata, alpha, by=c("ID"="group"))

plot <- meta_alpha %>%
    filter(!is.na(depth)) %>%
    group_by(depth) %>%
    summarize(mean_sobs=mean(sobs),
              mean_chao=mean(chao),
              mean_ace=mean(ace),
              mean_shannon=mean(shannon),
              mean_invsimpson=mean(invsimpson))

sobs <- ggplot(plot, aes(x=depth, y=mean_sobs)) +
  geom_boxplot(notch=TRUE) +
  labs(x="Depth", y="Number of OTUs") +
  theme_classic()
chao <- ggplot(plot, aes(x=depth, y=mean_chao)) +
  geom_boxplot(notch=TRUE) +
  labs(x="Depth", y="Number of OTUs") +
  theme_classic()
ace <- ggplot(plot, aes(x=depth, y=mean_ace)) +
  geom_boxplot(notch=TRUE) +
  labs(x="Depth", y="Number of OTUs") +
  theme_classic()
shannon <- ggplot(plot, aes(x=depth, y=mean_shannon)) +
  geom_boxplot(notch=TRUE) +
  labs(x="Depth", y="Shannon Diversity Index") +
  theme_classic()
invsimpson <- ggplot(plot, aes(x=depth, y=mean_invsimpson)) +
  geom_boxplot(notch=TRUE) +
  labs(x="Depth", y="Inverse Simpson Diversity Index") +
  theme_classic()
grid.arrange(sobs, chao, ace, shannon, invsimpson, nrow=2)

plot_arrange <- arrangeGrob(sobs, chao, ace, shannon, invsimpson, nrow=2)
ggsave("results/figures/calculators.jpg", plot_arrange, width=297, height=210, units="mm")


