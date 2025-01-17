####### FIGURE 4 ###########


# 1. LOADING --------------------------------------------------------------

if(!require(grid)){install.packages('grid'); library(grid)}
if(!require(gridExtra)){install.packages('gridExtra'); library(gridExtra)}
if(!require(tidyverse)){install.packages('tidyverse'); library(tidyverse)}
if(!require(ggplot2)){install.packages('ggplot2'); library(ggplot2)}
if(!require(viridis)){install.packages('viridis'); library(viridis)}
if(!require(ggridges)){install.packages('ggridges'); library(ggridges)}


# set colour palette
colviridis = viridis(7, begin = 0, end = 1, direction = 1, option = 'viridis')
alphaviridis = seq(from=0.1, to=1, by=0.1)
matviridis = matrix(NA, nrow = length(colviridis), ncol=length(alphaviridis))
rownames(matviridis) = c("FULL","SMALLWORLD","DEGREE","CLUSTERED","MODULAR","MOD_CLUST","MULTILEVEL")
for(i in 1:length(colviridis)){
  for(j in 1:length(alphaviridis)){
    matviridis[i,j] = alpha(colviridis[i], alphaviridis[j])
  }
}  

# reset full to greyscale
for(j in 1:length(alphaviridis)){
  matviridis[1,j]  = alpha('grey75', alphaviridis[j])
}



# 2. INPUT DATA -----------------------------------------------------------


## Data on cultural lineage diversity

# These data were generated by running the models in R available at the folder "/3_R_agent_based_models/". To facilitate the replicationof the figures, one can download data files from previous runs

# The first dataset is a large 1.3GB file thus it is not deposited in the repository. 
# Please download it first to your /3_R_agent_based_models/data/" folder using this link:
# https://owncloud.gwdg.de/index.php/s/nrm9MSb4jm64RnT
# Then load it
load("../../3_R_agent_based_models/data/props_all.RData")

# Load the other datasets, which are in the repository
load("../../3_R_agent_based_models/data/results_ABM1_2020-08-14_13_06_41.RData")
load("../../3_R_agent_based_models/data/results_ABM1_div_2020-08-14_13_06_41.RData")


## Data on time to recombination
load("../../2_Python_agent_based_models/data/df_TTC_m1.Rda")





# 2.1. Wrangle data ----

# Add columns
props_all$lineage = ifelse(props_all$medicin %>% str_detect('A'), 'A', 'B')
props_all$progress = ifelse(props_all$medicin %>% str_detect('2'), 2, 1)
props_all$progress = ifelse(props_all$medicin %>% str_detect('3'), 3, div$progress)
props_all$progress = ifelse(props_all$medicin %>% str_detect('C'), 4, div$progress)

# Get distribution for full and multilevel network where N = 64 and K = 12
full_64 = timings_all[timings_all$combined == '64_full_8',]
multi_64_8 = timings_all[timings_all$combined == '64_multilevel_12',]


# Define modes on log scale
full_mode = 6
multi_first = 2.5
multi_second = 6

# Find representatives
prox_mode = abs(log(full_64$epoch)-full_mode)
full_rep = props_all[props_all$combined == '64_full_8' & 
                       props_all$iteration ==  which(prox_mode == min(prox_mode))[1],]
prox_mode = abs(log(multi_64_8$epoch)-multi_first)
multi_rep1 = props_all[props_all$combined == '64_multilevel_12' & 
                       props_all$iteration ==  which(prox_mode == min(prox_mode))[1],]
prox_mode = abs(log(multi_64_8$epoch)-multi_second)
multi_rep2 = props_all[props_all$combined == '64_multilevel_12' & 
                       props_all$iteration ==  which(prox_mode == min(prox_mode))[1],]







# 3. DIVERSITY -----------------------------------------------------------

# Plot diversity for full network

divfull = 
  full_rep %>%
  filter(medicin != 'A1' & medicin != 'B1') %>% droplevels() %>% 
  # mutate(medicin = factor(medicin, 
  #                         levels = c('A1',  'A2',  'A3',  'AC',  'B1',  'B2',  'B3',  'BC'),
  #                         labels = c('Item', 'Dyad', 'Triad', 'Recombination', 'Item', 'Dyad', 'Triad', 'Recombination')))
  mutate(lineage = factor(lineage, levels = c('A', 'B'), labels=c('lineage A', 'lineage B'))) %>% 
  ggplot(aes(epoch, proportion, 
                         colour = lineage, group = medicin, 
                         size = as.factor(progress),
                         lty = as.factor(progress)
                         )) +
      geom_line() +
      scale_colour_manual(values = c(#matviridis[1,6],
                                     alpha('black', 0.55), alpha('black', 0.55))) +
      scale_size_manual(values = c(0.5, 1.5, 3), labels = c('Dyad', 'Triad', 'Recombination')) +
      scale_linetype_manual(values = c('solid', 'dashed',  'solid'), labels = c('Dyad', 'Triad', 'Recombination')) +
      labs(x = '', y = 'Proportion of the population',
           lty = '', size = '',
           title ='Fully connected') +
      ylim(0, 1) +
      scale_x_continuous(trans = 'log10', limits = c(1, 1000)) +
      theme_light() +
  facet_wrap(~lineage, nrow=2) +
      theme(legend.key.size = unit(1.0, "cm"),
            legend.position = "none", text=element_text(size=12),
            plot.margin=unit(c(0.1,0.1,0.1,0.1),"cm"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
           # axis.text.y = element_blank(),
            strip.background = element_blank(),
            strip.text = element_text(colour='black', size=12))

divfull <- arrangeGrob(divfull, top = textGrob(expression(bold("B")), x = unit(0, "npc")
        , y   = unit(1, "npc"), just=c("left","top"),
        gp=gpar(col="black", fontsize=14, fontfamily="Arial")))




# Plot diversity for second model of multilevel network

divmls2 = 
  multi_rep2 %>% 
  filter(medicin != 'A1' & medicin != 'B1') %>% droplevels() %>% 
  mutate(lineage = factor(lineage, levels = c('A', 'B'), labels=c('lineage A', 'lineage B'))) %>% 
  
  ggplot(aes(epoch, proportion, 
                            colour = lineage, group = medicin, 
                            size = as.factor(progress),
                            lty = as.factor(progress)
                            )) +
      geom_line() +
    scale_colour_manual(values = c(as.character(matviridis[7,6]), as.character(matviridis[7,6])), guide = FALSE) +
  # scale_size_manual(values = c(0.5, 1.5, 1.5, 3), labels = c('Item', 'Dyad', 'Triad', 'Recombination')) +
      # scale_linetype_manual(values = c('solid', 'dotted','dashed',  'solid'), labels = c('Item', 'Dyad', 'Triad', 'Recombination')) +
      scale_size_manual(values = c(0.5, 1.5, 3), labels = c('Dyad', 'Triad', 'Recombination')) +
      scale_linetype_manual(values = c('solid', 'dashed',  'solid'), labels = c('Dyad', 'Triad', 'Recombination')) +
      labs(y = '', x = '',
           lty = '', size = '',
           title ='Multilevel (**second mode)') +
      ylim(0, 1) +
      scale_x_continuous(trans = 'log10', limits = c(1, 1000)) +
    facet_wrap(~lineage, nrow=2) +
      theme_light() +
          theme(
        strip.background = element_blank(),
      #  strip.text = element_text(colour='black', size=12),
        axis.text.y = element_blank(),
     legend.position = c(0.5, .45),
     legend.justification = c("center", "top"),
     legend.box.just = "center",
     legend.margin = margin(),
     legend.text = element_text(size = 10),
     legend.key = element_rect(colour = "transparent", fill = "transparent"),
     legend.title=element_blank(),
     legend.box="vertical",
            legend.key.size = unit(1.0, "cm"),
            plot.margin=unit(c(0.1,0.1,0.1,0.1),"cm"),
            text=element_text(size=12),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank()) +
 # guides(colour = guide_legend(nrow = 1)) +
  guides(size = guide_legend(nrow = 2))

divmls2 <- arrangeGrob(divmls2, top = textGrob(expression(bold("D")), x = unit(0, "npc")
        , y   = unit(1, "npc"), just=c("left","top"),
        gp=gpar(col="black", fontsize=14, fontfamily="Arial")))




# Plot diversity for first mode of multilevel network

divmls1 = 
  multi_rep1 %>% 
  
  filter(medicin != 'A1' & medicin != 'B1') %>% droplevels() %>% 
  mutate(lineage = factor(lineage, levels = c('A', 'B'), labels=c('lineage A', 'lineage B'))) %>% 

  ggplot(aes(epoch, proportion, 
                         colour = lineage, group = medicin, 
                         size = as.factor(progress),
                         lty = as.factor(progress))) +
      geom_line() +
     # scale_colour_manual(values = c(as.character(matviridis[7,10]), as.character(matviridis[7,5]))) +
      # scale_colour_manual(values = c(colviridis[7], alpha('orange', 0.5)),
      #                     guide = FALSE) +
    scale_colour_manual(values = c(as.character(matviridis[7,6]), as.character(matviridis[7,6])), guide = FALSE) +
    # scale_size_manual(values = c(0.5, 1.5, 1.5, 3), labels = c('Item', 'Dyad', 'Triad', 'Recombination')) +
      # scale_linetype_manual(values = c('solid', 'dotted','dashed',  'solid'), labels = c('Item', 'Dyad', 'Triad', 'Recombination')) +
      scale_size_manual(values = c(0.5, 1.5, 3), labels = c('Dyad', 'Triad', 'Recombination')) +
      scale_linetype_manual(values = c('solid', 'dashed',  'solid'), labels = c('Dyad', 'Triad', 'Recombination')) +
      labs(y = '', x = 'Time (epoch)',
           lty = '', size = '', #colour='',
           title ='Multilevel (*first mode)') +
      ylim(0, 1) +
      scale_x_continuous(trans = 'log10', limits = c(1, 1000)) +
    facet_wrap(~lineage, nrow=2) +
      theme_light() +
  theme(legend.key.size = unit(1.0, "cm"),
            legend.position = "none", text=element_text(size=12),
            plot.margin=unit(c(0.1,0.1,0.1,0.1),"cm"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            axis.text.y = element_blank(),
            strip.background = element_blank())#,
            #strip.text = element_text(colour='black', size=12))


divmls1 <- arrangeGrob(divmls1, top = textGrob(expression(bold("C")), x = unit(0, "npc")
        , y   = unit(1, "npc"), just=c("left","top"),
        gp=gpar(col="black", fontsize=14, fontfamily="Arial")))




# 4. RIDGES -----------------------------------------------------------

# Plot ridges for full and multilevel networks

cu = df_TTC_m1

# Set small population size N=64, low degree K=12, include fully connected networks
cu = cu[which(cu$degree==12 | cu$degree=='N-1'),]
cu = cu[which(cu$pop_size==64),]


# pick the poor null model (full), the low end of the spectrum and good null model (degree), and the high end of the spectrum (multilevel)
cu = cu[which(cu$graph=='full' | cu$graph=='multilevel'),]
cu = cu %>%
dplyr::mutate(graph = factor(graph, levels = c("multilevel", 'full'),
                            labels = c("Multilevel", 'Fully connected')))

rids_ttcm1_div = cu %>%
ggplot(aes(x = log(epoch+1), y = graph)) +
     geom_density_ridges(aes(fill = graph), scale = 3, size = 0.3, jittered_points = F,
                         bandwidth = 0.18#,
                        #quantile_lines = T, quantiles = 2
                        ) +
  scale_fill_manual(values = as.character(matviridis[c(7,1),6]),
                    name = "") +  
  scale_x_continuous(limits = c(0, 8), expand = c(0, 0), labels = c('1', '10',  '100', '1000'), breaks = c(0, 2.31, 4.608, 6.908)) +
#  labs(x = 'Time to recombination with \n one-to-many diffusion (epoch)', y = '') +
  labs(x = 'Time (epoch)', y = 'Network size N=64, Connectivity K=12') +
  #theme_ridges() + 
  theme_light() +
  theme(legend.position = "none",
        axis.title.x = element_text(vjust = 0.5, hjust = 0.5),
        axis.title.y  = element_text(vjust = 0.5, hjust = 0.5),
        plot.margin=unit(c(0.1,0.1,0.1,0.1),"cm"),
        legend.key.size = unit(1.0, "cm"),
        text=element_text(size=12),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.y = element_blank()
        ) +
  guides(shape = guide_legend(override.aes = list(size = 0.1))) +
  guides(color = guide_legend(override.aes = list(size = 0.1))) +
   ggtitle("Time to recombination")

# Annotate distribution modes and network types
mode1 <- grobTree(textGrob("*", x=0.3,  y=0.63, hjust=0, gp=gpar(col="black", fontsize=18, fontface="bold")))
mode2 <- grobTree(textGrob("**", x=0.67,  y=0.29, hjust=0, gp=gpar(col="black", fontsize=18, fontface="bold")))
mtl <- grobTree(textGrob("Multilevel", x=0.60,  y=0.155, hjust=0, gp=gpar(col="black", fontsize=12, fontface="plain")))
fuc <- grobTree(textGrob("Fully connected", x=0.57,  y=0.37, hjust=0, gp=gpar(col="black", fontsize=12, fontface="plain")))
rids_ttcm1_div = rids_ttcm1_div + annotation_custom(mode1) + annotation_custom(mode2) + annotation_custom(mtl) + annotation_custom(fuc)

rids_ttcm1_div <- arrangeGrob(rids_ttcm1_div, top = textGrob(expression(bold("A")), x = unit(0, "npc")
        , y   = unit(1, "npc"), just=c("left","top"),
        gp=gpar(col="black", fontsize=14, fontfamily="Arial")))







# 5. PLOTTING -------------------------------------------------------------


grid.arrange(rids_ttcm1_div, divfull, divmls1, divmls2,
             ncol=4)
