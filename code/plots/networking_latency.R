library(ggplot2)
library(dplyr)
library(rio)
library(here)
# library(extrafont)
# loadfonts()
here::i_am('code/plots/networking_latency.R')

lates <- import(here('data', 'networking', 'network_latency.csv'))
# Filter to session 10, which is the complete one with latest code version
lates <- lates %>% filter(session==20)
# remove the first few trials, which are slow because they need to open the connection
lates <- lates[4:nrow(lates),]

lates$latency <- as.numeric(lates$latency * 1000)
lates <- lates[!is.na(lates$latency),]

dens <- density(lates$latency, na.rm=TRUE)
df <- data.frame(x=dens$x, y=dens$y)
probs <- c(0.25, 0.5, 0.75)
quantiles <- quantile(lates$latency, prob=probs)
df$quant <- factor(findInterval(df$x,quantiles))

g_latency <- ggplot(lates)+
  geom_ribbon(data=df, aes(x=x, y=y,ymin=0, ymax=y, fill=quant))+
  geom_density(aes(x=latency), trim=FALSE)+
  scale_x_continuous(limits=c(0,2),
                     breaks=c(0,1,2,3,as.numeric(quantiles)))+
  geom_point(aes(x=latency, y=-7.5),
             position=position_jitter(height=7.5, width=0),
             alpha=0.01, size=0.5)+
  scale_fill_manual(values=c("#ffcccc","#ffaaaa" ,"#ff6666" , "#ff0000"), guide="none")+
  theme_minimal()+
  theme(
    plot.background = element_rect(fill="#ffffff"),
    panel.grid = element_blank(),
    axis.ticks.x = element_line(),
    axis.text.y = element_blank()
  )+
  labs(x="Latencies (ms)", y="density")
# geom_point(aes(x='latencies'), )
g_latency

ggsave(here('code',"rendered_figures","networking_latency.pdf"), g_latency,
       width=4.1,height=1.25, units="in")
