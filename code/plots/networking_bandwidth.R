library(ggplot2)
library(tidyverse)
library(rio)
library(here)

library(sitools)
# library(extrafont)
# loadfonts()
here::i_am('code/plots/networking_bandwidth.R')

netroot <- here('data', 'networking')
bw_files <- list.files(path=here('data', 'networking'), pattern="bandwidth*", full.names=TRUE)

bw <- bw_files %>% map_df(~read_csv(.))

bw$msg_throughput <- bw$message_size * bw$actual_rate
bw$payload_throughput <- bw$payload_size * bw$actual_rate

g_bandwidth <- ggplot(bw, aes(x=message_size, y=actual_rate, color=interaction(blosc, random)))+
  geom_line()+
  geom_point()+
  scale_x_log10(labels=f2si)
g_bandwidth

g_bandwidth_msg_throughput <- ggplot(bw, aes(x=payload_size, y=msg_throughput, color=interaction(blosc, random)))+
  geom_line()+
  scale_x_log10(labels=f2si)+
  scale_y_continuous(labels=f2si)
g_bandwidth_msg_throughput

g_bandwidth_payload_throughput <- ggplot(bw, aes(x=payload_size, y=payload_throughput, color=interaction(blosc, random)))+
  geom_line()+
  geom_point()+
  scale_x_log10(labels=f2si)+
  scale_y_continuous(labels=c("0", "50MB/s", "100MB/s", "150MB/s", "200MB/s"), breaks=c(0, 50000000, 100e6, 150e6, 200e6))
g_bandwidth_payload_throughput

# wide to long
bw_long <- bw %>% pivot_longer(
  cols=c(payload_throughput, msg_throughput),
  names_to="throughput_type",
  values_to="throughput"
  )

g_throughput <- ggplot(
  bw_long,
  aes(
    x=payload_size, 
    y=throughput,
    color=random,
    linetype=blosc))+
  scale_color_manual(values=c("#FF0000", "#000000"))+
  geom_line()+
  geom_point()+
  scale_x_log10(labels=f2si)+
  scale_y_log10(labels=f2si)+
  annotation_logticks(size=0.25)+
  facet_grid(.~throughput_type)+
  labs()+
  theme_minimal()+
  theme(
    plot.background = element_rect(fill="#ffffff"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(hjust=1,angle=45),
    legend.position='top'
  )
g_throughput

ggsave(here('code',"rendered_figures","networking_bandwidth.pdf"), g_throughput,
       width=4.1,height=2.75, units="in")
  

lates <- import(here('data', 'networking', 'network_latency.csv'))