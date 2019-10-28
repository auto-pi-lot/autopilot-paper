library(psych)
library(ggplot2)
library(plyr)
library(lme4)
library(lmerTest)
library(here)

n_sims <- 1000

sims <- expand.grid(
  i_sim     =  seq(n_sims),
  icc       =  c(0.002, 0.02, 0.2, 0.8),
  #n_cells   =  c(10, 25, 50, 100, 500, 1000),
  n_cells = c(10,20,30,40,50,60,70,80,90,100),
  n_animals =  c(5)
)


setwd(here('data'))
saveRDS(sims, 'nesting_sim.RData')

sims_sum <- ddply(sims, .(n_animals, n_cells, icc), summarize,
                  mean_pt = mean(p_t),
                  #mean_pml = mean(p_ml),
                  pt_fpr = sum(p_t<0.05)/length(p_t))
                  #pml_fpr = sum(p_ml<0.05)/length(p_ml))


ggplot(sims_sum, aes(x=n_cells, color=as.factor(icc), group=as.factor(icc)))+
  geom_hline(yintercept=0.05, linetype="dotted")+
  geom_line(aes(y=pt_fpr))+
  scale_y_continuous(limits=c(0,1))+
  #scale_x_log10()+
  #annotation_logticks(sides='b')+
  # geom_line(aes(y=mean_pt), color="black", size=1)+
  # geom_line(aes(y=pt_fpr), color="red", size=1)+
  # geom_line(aes(y=pml_fpr), color="blue", size=1)+
  theme_minimal()+
  theme(panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank())
ggsave(here('figures','fpr_render.pdf'),g.fpr , width=5, height=3, units="in")
