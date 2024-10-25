#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)
library(tidyr)

pre <- read.csv("Results/OG_filtered.csv", header = T)
herro <- read.csv("Results/Herro_corrected.csv", header = T)


####Filter out perfect alignments ####

#get list of perfect alignment  before error correction - mapq60 (dont want after error correction as may be perfect due to error correction which is waht we want to detec)

##Only compare those reads in both pre and herro since more in pre subset pre to
#those that made it through error correction

##Only those that didnt start as perfect alingments
pre_fil <- pre %>% filter(alignmentMapq < 60)
herro_fil <- herro %>% filter(X.read %in% pre_fil$X.read)


###primary alignments only ###
pre_prim <- pre_fil %>% filter(alignmentType == "Primary")
herro_prim <- herro_fil %>% filter(alignmentType == "Primary")


###Only those reads n both pre and herro ###


reads_in_both <- intersect(herro_prim$X.read, pre_prim$X.read)


df_test <- bind_rows(lst(pre_prim, herro_prim), .id = 'id' )
df_test$id <- as.factor(df_test$id)

df_uniq <- df_test %>% filter(X.read %in% reads_in_both)


plot <- ggplot(df_uniq, aes(x = id, y = concordanceQv)) +
  geom_violin(trim = F)


Ttest <- t.test(concordanceQv ~ id, data = df_uniq, paired = TRUE)

Summary_table_pre <-df_uniq %>% filter(id == "pre_prim" )  %>% summarise(across(where(is.numeric), .fns = 
                         list(mean = mean,
                              stdev = sd,
                              median = median,
                              min = min,
                              q25 = ~quantile(., 0.25),
                              q75 = ~quantile(., 0.75),
                              max = max))) %>%
  pivot_longer(everything(), names_sep='_', names_to=c('variable', '.value')) %>% mutate(ID = "Pre")


Summary_table_herro <- df_uniq %>% filter(id == "herro_prim" )  %>% summarise(across(where(is.numeric), .fns = 
                                                                                  list(mean = mean,
                                                                                       stdev = sd,
                                                                                       median = median,
                                                                                       min = min,
                                                                                       q25 = ~quantile(., 0.25),
                                                                                       q75 = ~quantile(., 0.75),
                                                                                       max = max))) %>%
  pivot_longer(everything(), names_sep='_', names_to=c('variable', '.value')) %>% mutate(ID = "Herro")


Summary_table <- rbind(Summary_table_pre, Summary_table_herro)
write.csv(Summary_table, file = 'Results/Error_correction_summary.csv', row.names = F)
chars <- capture.output(print(Ttest))
writeLines(chars, con = file("Results/Error_correction_Ttest.txt"))
ggsave("Results/HerroVsOG.png", plot)



