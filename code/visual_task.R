# set path to base repo directory
setwd('../')
library(ggplot2)
library(rio)
library(here)

library(tidyverse)
library(ggridges)

###########
# Visual onset latency


visual <- import(here('data', 'visual_lag.csv'))

color_vals = c("#ff0000", "#187cd6", "#9102d3", "#00AF3F", "#FF7900", "#000000")

g.visual_lag <- ggplot(visual, aes(x=lag, y=0))+
  geom_dotplot(aes(y=0),dotsize=1,stackratio=1.25)+
  stat_density_ridges(geom="density_ridges_gradient",
                      quantile_lines=TRUE, fill=NA,vline_color="red")+
  scale_y_continuous(limits=c(0,0.16))+
  scale_x_continuous(breaks=c(20,25,30,35,40,45),expand=c(0,0))+
  theme(panel.background = element_blank(),
        panel.grid=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank())

ggsave(here('figures','test_6_visual_lags_render.pdf'), plot=g.visual_lag, width=2.4, height=1.5, units="in", useDingbats=FALSE)



##############
# Framerates

framerate_files <- list.files(here('data', 'frame_test_2'), full.names=TRUE)

import_frames <- function(f){
  frame_df <- data.frame(t(import(f)))
  names(frame_df) <- c('interval')
  frame_df$n_frame <- seq(nrow(frame_df))
  # get timestamp from file name
  fname <- basename(f)
  fname <- str_remove(fname, 'frameintervals_')
  fname <- str_remove(fname, '.csv')
  fname <- str_remove(fname, '\\.\\d*')
  frame_df$trial <- as.POSIXct(fname, format='%Y-%m-%dT%H:%M:%S')
  return(frame_df)
}

frames <- bind_rows(lapply(framerate_files, import_frames))
# filter last interval
frames <- frames %>% group_by(trial) %>%
  filter(n_frame < max(n_frame))

ggplot(frames, aes(x=n_frame, y=interval, group=trial, color=trial))+
  geom_line()

frame_sum <- frames %>%
  summarize(median_fr = median(1/interval),
            sd_interval = sd(interval),
            sd_fr = sd(1/interval))

ggplot(frames, aes(x=1/interval))+
  stat_density_ridges(aes(y=1),quantile_lines=TRUE)

ggplot(frame_sum, aes(x=trial))+
  geom_pointrange(aes(y=mean_fr, ymin=mean_fr-sd_fr, ymax=mean_fr+sd_fr))

frames$afactor <- factor('')

g.frames <- ggplot(frames, aes(x=1/interval, y=afactor))+
  #geom_dotplot(aes(y=0),dotsize=1,stackratio=1.25)+
  stat_density_ridges(geom="density_ridges_gradient",
                      quantile_lines=TRUE, fill=NA,vline_color="red")+
  #scale_y_continuous(limits=c(0,0.16))+
  scale_x_continuous(breaks=c(30, 32, 34, 36, 38),expand=c(0,0),limits=c(29,37))+
  theme(panel.background = element_blank(),
        panel.grid=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank())


ggsave(here('figures','test_7_fps_render.pdf'), plot=g.frames, width=2.4, height=1.5, units="in", useDingbats=FALSE)

ggplot(frames, aes(x=n_frame*as.numeric(as.factor(trial)), y=1/interval))+
  geom_point()+
  geom_smooth()

sd_fps <- function(meanint, sdint){
  fps <- 1/(meanint/1000)
  sd_fps <- fps-(1/((meanint+sdint)/1000))
  return(c(fps, sd_fps))
}
