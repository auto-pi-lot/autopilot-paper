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
  scale_x_log10(labels=f2si)
g_bandwidth

g_bandwidth_msg_throughput <- ggplot(bw, aes(x=payload_size, y=msg_throughput, color=interaction(blosc, random)))+
  geom_line()+
  scale_x_log10(labels=f2si)+
  scale_y_continuous(labels=f2si)
g_bandwidth_msg_throughput

g_bandwidth_payload_throughput <- ggplot(bw, aes(x=payload_size, y=payload_throughput, color=interaction(blosc, random)))+
  geom_line()+
  scale_x_log10(labels=f2si)+
  scale_y_continuous(labels=f2si)
g_bandwidth_payload_throughput

lates <- import(here('data', 'networking', 'network_latency.csv'))