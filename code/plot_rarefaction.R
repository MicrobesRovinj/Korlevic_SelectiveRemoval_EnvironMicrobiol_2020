#################################################################################################################
# plot_rarefaction.R
# 
# A script to plot the rarefaction curve of each sample.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.groups.rarefaction
#               data/raw/metadata.csv
# Produces: results/figures/rarefaction.jpg
#
#################################################################################################################

# Loading input data and selection of values for plotting
rarefaction <- read_tsv(file="data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.pick.pick.pick.opti_mcc.groups.rarefaction") %>%
  select(-contains("lci-"), -contains("hci-")) %>%
  gather(-numsampled, key=sample, value=sobs) %>%
  mutate(sample=str_replace_all(sample, pattern="0.03-", replacement="")) %>%
  drop_na()

# Loading metadata
Sys.setlocale(locale="en_GB.utf8")
metadata <- read_tsv("data/raw/metadata.csv") %>%
  mutate(date=as.Date(date, "%d.%m.%Y")) %>%
  arrange(date) %>%
  mutate(date=format(date, "%d %B %Y")) %>%
  mutate(date=str_replace(date, "^0", ""))

# Joining metadata and input data
metadata_rarefaction <- inner_join(metadata, rarefaction, by=c("ID"="sample"))

# Defining line color and type for each sampling date
color_type <- tribble(~label, ~color,
                      "4/12-17 SCy", "#A6CEE3",
                      "4/12-17 FCyM", "#1F78B4",
                      "4/12-17 FCaM", "#33A02C",
                      "4/12-17 FCa", "#FB9A99",
                      "19/6-18 FCyM", "#E31A1C",
                      "19/6-18 FCaM", "#FF7F00",
                      "19/6-18 FCa", "#6A3D9A")

# Generating a common theme for plots
theme <- theme(text=element_text(family="Times"), line=element_line(color="black"),
               panel.border=element_rect(fill=NA), panel.background=element_blank(),
               panel.grid=element_blank(), axis.line=element_blank(),
               axis.text=element_text(size=12, color="black"), axis.title=element_text(size=14, color="black"),
               plot.margin=unit(c(5.5, 16.5, 5.5, 5.5), "pt"), legend.position="none",
               plot.title=element_text(size=16, hjust=0.5))

# Plots generation
p <- metadata_rarefaction %>%
  mutate(label=factor(label, levels=color_type$label)) %>%
  ggplot(aes(x=numsampled, y=sobs, color=label)) +
  geom_line(size=1.5) +
  scale_colour_manual(values=set_names(color_type$color, color_type$label),
  labels=c("4/12-17 SCy"=parse(text="plain('Saline, ')~plain('4 December 2017, ')~italic('Cymodocea nodosa ')~plain('(Monospecific)')"), 
           "4/12-17 FCyM"=parse(text="plain('Funtana, ')~plain('4 December 2017, ')~italic('Cymodocea nodosa ')~plain('(Mixed)')"),
           "4/12-17 FCaM"=parse(text="plain('Funtana, ')~plain('4 December 2017, ')~italic('Cymodocea nodosa ')~plain('(Mixed)')"),
           "4/12-17 FCa"=parse(text="plain('Funtana, ')~plain('4 December 2017, ')~italic('Cymodocea nodosa ')~plain('(Monospecific)')"),
           "19/6-18 FCyM"=parse(text="plain('Funtana, ')~plain('19 June 2018, ')~italic('Cymodocea nodosa ')~plain('(Mixed)')"),
           "19/6-18 FCaM"=parse(text="plain('Funtana, ')~plain('19 June 2018, ')~italic('Cymodocea nodosa ')~plain('(Mixed)')"),
           "19/6-18 FCa"=parse(text="plain('Funtana, ')~plain('19 June 2018, ')~italic('Cymodocea nodosa ')~plain('(Monospecific)')"))) +
  labs(x="Number of Sequences", y="Number of OTUs") +
  theme +
  theme(legend.position=c(0.67, 0.18), legend.title=element_blank(),
        legend.text=element_text(size=10, margin=margin(r=0.2, unit="cm")),
        legend.key.width=unit(1.4, "cm"), legend.key.height=unit(0.5, "cm"),
        legend.key=element_rect(fill="white"), legend.justification=c("top"),
        legend.text.align=0, legend.spacing.x=unit(0, "cm")) +
  guides(color=guide_legend(ncol=1))

# Plot saving
ggsave("results/figures/rarefaction.jpg", p, width=210, height=297, units="mm")