library(ggplot2)
library(rio)
library(here)
# library(extrafont)
# loadfonts()
here::i_am('code/plots/sound_latency.R')

lates <- import(here('data', 'sound_latency', 'sound-latency_192k_n2_p32_0_extracted.csv'))
lates$latencies <- lates$latencies * 1000
lates <- lates[!is.na(lates$latencies),]

dens <- density(lates$latencies, na.rm=TRUE)
df <- data.frame(x=dens$x, y=dens$y)
probs <- c(0.25, 0.5, 0.75)
quantiles <- quantile(lates$latencies, prob=probs)
df$quant <- factor(findInterval(df$x,quantiles))

g_latency <- ggplot(lates)+
  geom_ribbon(data=df, aes(x=x, y=y,ymin=0, ymax=y, fill=quant))+
  geom_density(aes(x=latencies), trim=FALSE)+
  scale_x_continuous(limits=c(0,3),
                     breaks=c(0,1,2,3,as.numeric(quantiles)))+
  geom_point(aes(x=latencies, y=-0.5),
             position=position_jitter(height=0.5, width=0),
             alpha=0.2, size=0.5)+
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

ggsave(here('code',"rendered_figures","sound_latency.pdf"), g_latency,
       width=4.1,height=1.25, units="in")
