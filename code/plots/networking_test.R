
setwd('../')
#here::set_here()
library(ggplot2)
library(rio)
library(here)
library(tidyverse)
library(sitools)

data_dir <- here('data','network_tests')


# single pi limits


test_files <- list.files(data_dir)
pi4_files <- test_files[str_detect(test_files, '^pi4')]

pi4 <- bind_rows(lapply(paste0(data_dir, pi4_files), import))

ggplot(pi4, aes(x=mean_delay, y=actual_rate))+
  geom_point()


########
# multipi

multi_files <- test_files[str_detect(test_files, '0size.csv$')]

multi <- bind_rows(lapply(paste0(data_dir, multi_files), import))

multi$total_rate <- multi$actual_rate * multi$n_pilots

#subzeros <- multi$mean_delay < 0.001
#multi[subzeros,]$mean_delay <- rnorm(sum(subzeros),0.01, 0.0001)

multi$mean_delay <- multi$mean_delay - min(multi$mean_delay)
g.bandwidth <- ggplot(multi, aes(x=mean_delay, y=total_rate, color=as.factor(n_pilots)))+
  geom_point()+
  scale_x_log10()+
  labs(x="Mean Delay (s)", color="# senders",
       y="Message rate (Hz)", title="Autopilot Network Superhighway")+
  annotation_logticks(sides="b", color="#eeeeee")+
  scale_color_brewer(palette="Set2")+
  theme(panel.background = element_rect(fill="#222222"),
        legend.position="right",
        panel.grid.minor=element_blank(),
        panel.grid.major.x=element_blank(),
        panel.grid.major.y = element_line(color="#cccccc"),
        legend.key = element_blank(),
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(0,0,0,0,'pt'),
        legend.background = element_blank(),
        plot.background = element_rect(fill="#222222"),
        axis.title=element_text(family="Fedra Sans Std Medium", color="#ffffff",size=12),
        title=element_text(family="Gotham", color="#ffffff",size=14),
        legend.title=element_text(family="Fedra Sans Std Medium", color="#ffffff",size=12),
        axis.text=element_text(family="Fedra Mono Light", color="#eeeeee"),
        legend.text = element_text(family="Fedra Mono Light", color="#eeeeee")
        )

ggsave(here('figures','test_2_bandwidth.png'), g.bandwidth,
       width=16/3, height=9/3, units="in")


####################################
# Speed tests
speed_files <- list.files(paste0(data_dir, 'speed_tests/'))
speed <- bind_rows(lapply(paste0(data_dir,'speed_tests/',speed_files), import))
speed$total_rate <- speed$actual_rate*speed$n_pilots

speed <- speed %>% arrange(total_rate)


goodlines <- speed %>%
  filter(n_pilots <=2) %>%
  filter(!((n_pilots == 1) & (mean_delay>0.03))) %>%
  filter(!((n_pilots == 2) & (total_rate>1400)))

delay <- mean(speed[speed$mean_delay<0.009,]$mean_delay*1000)
nominal_delay_sd <- sd(speed[speed$mean_delay<0.009,]$mean_delay*1000)
delaylo = delay-nominal_delay_sd
delayhi = delay+nominal_delay_sd


delay_df <- data.frame(delay = delay, 
                            delaylo = delaylo,
                            delayhi = delayhi,
                            xpos = 0)


network_theme <- theme(
  panel.background = element_blank(),
  panel.grid = element_blank(),
  legend.position= 'top',
  legend.key = element_blank(),
  legend.margin=margin(0,0,0,0),
  legend.box.margin=margin(0,0,0,0,'pt'),
  # title=element_text(family="Gotham", color="#000000",size=unit(12,'pt')),
  # legend.title=element_text(family="Fedra Sans Std Medium", color="#000000",size=unit(10,'pt')),
  # axis.text=element_text(family="Fedra Mono Light", color="#000000", size=unit(9,'pt')),
  # legend.text = element_text(family="Fedra Mono Light", color="#000000", size=unit(9,'pt')),
  # axis.title=element_text(family="Fedra Sans Std Medium", color="#000000",size=unit(10,'pt')),
)

color_vals = c("#ff0000", "#187cd6", "#9102d3", "#00AF3F", "#FF7900", "#000000")

g.speed <- ggplot(speed, aes(y=mean_delay*1000, x=total_rate, color=as.factor(n_pilots)))+
  annotation_logticks(sides="l")+
  geom_smooth(data=speed[speed$n_pilots>2,],se=FALSE,color="black")+
  geom_smooth(data=goodlines,se=FALSE)+
  geom_crossbar(data=delay_df, aes(y=delay,x=xpos,ymin=delaylo,ymax=delayhi),color="black")+
                  #aes(x=xpos,y=delay,ymin=delaylo,ymax=delayhi,color="red"))+
  scale_x_continuous(limits=c(0,2500))+
  scale_y_log10(limits=c(1, 500), breaks=c(1,10, 100, 500))+
  geom_point()+
  labs(x="Message Rate (Hz)", y="Mean Delay (ms)", color="# Pilots")+
  scale_color_manual(values=color_vals, limits=c("1", "2", "4", "6", "8", "10"))+
  #scale_color_brewer(palette="Set2")+
  guides(color=guide_legend(nrow=1))+
  network_theme

ggsave(here('figures', 'test_2_speed_render.pdf'), g.speed,
       width=2.4*2, height=1.5*2,units="in",useDingbats=FALSE)


###################
payload_files <- list.files(paste0(data_dir, 'size_tests/'))
payload <- bind_rows(lapply(paste0(data_dir,'size_tests/',payload_files), import))
payload$total_rate <- payload$actual_rate*payload$n_pilots
payload <- bind_rows(payload, speed)
payload$throughput <- payload$message_size * payload$total_rate

max_payload <- payload %>% group_by(n_pilots, message_size) %>%
  summarize(throughput = max(throughput),
            total_rate = max(total_rate))

g.payload <- ggplot(max_payload, aes(x=message_size, y=throughput, color=as.factor(n_pilots)))+
  geom_line()+
  labs(x="Message Size (Bytes)", y="Max Throughput (Bytes)")+
  scale_x_continuous(breaks=c(0,100000,200000,300000),labels=f2si)+
  scale_y_continuous(labels=f2si)+
  scale_color_manual(values=color_vals, limits=c("1", "2", "4", "6", "8", "10"))+
  guides(color=guide_legend(nrow=1))+
  network_theme
g.payload

ggsave(here('figures', 'test_3_throughput_render.pdf'), g.payload,
       width=2.4*2, height=1.5*2,units="in",useDingbats=FALSE)

ggplot(payload, aes(x=throughput, y=mean_delay,color=as.factor(n_pilots)))+
  geom_point()

###############################
pi4_max <- import(paste0(data_dir,'pi4_tests/maxspeed_sizes.csv'))
pi4_max$throughput <- pi4_max$message_size * pi4_max$actual_rate

pi4_speed <- import(paste0(data_dir,'pi4_tests/speed_1.csv'))

pi4_files <- paste0(data_dir,'pi4_tests/', list.files(paste0(data_dir,'pi4_tests/')))
pi4_all <- bind_rows(lapply(pi4_files, import))
pi4_all$throughput <- pi4_all$actual_rate * pi4_all$message_size



ggplot(pi4_max, aes(x=message_size, y=throughput))+
  geom_point()+
  scale_y_continuous(labels=f2si)


delays <- c(mean(speed[speed$n_pilots==1 & speed$actual_rate<600,]$mean_delay), mean(pi4_speed[pi4_speed$actual_rate<1200,]$mean_delay))
rates <- c(max(speed[speed$n_pilots==1,]$actual_rate), max(pi4_all$actual_rate))
jitter <- c(mean(speed[speed$n_pilots==1,]$delay_jitter), mean(pi4_speed$delay_jitter))
throughs <- c(max(payload[payload$n_pilots==1,]$throughput), max(pi4_all$throughput))
pi4_comparison <- data.frame(pi = c("Pi3b", "Pi4"),
                             delay = delays,
                             rate = rates,
                             jitter = jitter,
                             throughput = throughs)

pi4_comp <- pi4_comparison %>%
  gather(key="key", value="value",delay:throughput)

g.comparison <- ggplot(pi4_comp, aes(x=key, y=value, fill=pi))+
  geom_col(position="dodge")+
  coord_flip()+
  facet_wrap(key~., ncol=1, scales="free")+
  theme_minimal()+
  theme(
    legend.position="top",
    panel.grid = element_blank()
  )

ggsave(here('figures', 'test_4_comparison_render.pdf'), g.comparison,
       width=2.4*2, height=2.4*2,units="in",useDingbats=FALSE)

######
# drops

# load the rest of the tests
multi_files <- paste0(data_dir,'multipi_tests/', list.files(paste0(data_dir,'multipi_tests/')))
multi_tests <- bind_rows(lapply(multi_files,import))


all_tests <- bind_rows(speed, payload, pi4_all, multi_tests)
all_tests$n_total_messages <- all_tests$n_messages*all_tests$n_pilots
all_tests$dropped_messages <- (all_tests$drop_rate*all_tests$n_messages)*all_tests$n_pilots

all_tests[all_tests$drop_rate>0,]


total_dropped <- sum(all_tests$dropped_messages)
total_sent <- sum(all_tests$n_total_messages)

(total_sent-total_dropped)/total_sent

