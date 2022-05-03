setwd('../')
#here::set_here()
library(ggplot2)
library(rio)
library(here)


apilot <- import(here('data', 'autopilot_latency_082019.csv'))
#tests <- data.frame(lags=tests[1:51, "latency"])
apilot <- data.frame(lags=apilot$delay)
apilot$systems <- 'autopilot'

bpod <- import(here('data','bpod_latency_xonar.csv'))
bpod <- data.frame(lags=bpod[,"latency"])
bpod$systems <- 'bpod (observed)'


tests <- rbind(apilot, bpod)

mean_lag <- mean(apilot$lags)
bpod_lag <- mean(bpod$lags)
system_names <- c("autopilot", "bpod (reported)", "pyControl", "bpod (observed)")
mean_lags <- data.frame(systems = ordered(system_names, levels=rev(system_names)),
                        lags = c(mean_lag, 7.5, 15, bpod_lag))

g.lags <- ggplot(mean_lags, aes(x=systems, y=lags))+
  geom_bar(aes(x=systems, y=lags),
           fill=c("#187cd6", "#ff2020", "#ff2020","#187cd6"),
           stat="identity")+
  geom_point(data=tests,
             position=position_jitter(height=0,width=0.3),
             alpha=0.15,
             color="#000000",
             size=0.5)+
  coord_flip()+
  theme_minimal()+
  theme(panel.grid.minor.x=element_blank(),
        panel.grid.major.y = element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_text(margin=unit(c(0,-6,0,0), units='pt')))

ggsave(here('figures','test_1_lags_render.pdf'), plot=g.lags, width=4.1, height=1.3, units="in", useDingbats=FALSE)


###################
# visual latency
