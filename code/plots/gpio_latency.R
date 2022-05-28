library(ggplot2)
library(rio)
library(here)
library(tidyverse)
library(magrittr)
# library(extrafont)
# loadfonts()
here::i_am('code/plots/gpio_latency.R')

# read/write and write-only test data
# all times are in nanoseconds, so we divide by 1000 to get microseconds
rw_json <- import(here('data', 'gpio_latency', 'tests-gpio-write-220427T030954.json'))
# read/write times
rw_times <- rw_json$times[[1]]/1000
# write-only times
ro_times <- rw_json$times[[2]]/1000

# gpiozero data 
zero_json <-  import(here('data', 'gpio_latency', 'tests-gpio-writezero-220427T222641.json'))
gz_times <- zero_json$times[[1]]/1000

# summary df
df <- data.frame(
  test=c("readwrite", "writeonly", "zero"),
  med=c(median(rw_times), median(ro_times), median(gz_times)),
  q1=c(quantile(rw_times, 0.25), quantile(ro_times, 0.25), quantile(gz_times, 0.25)),
  q3=c(quantile(rw_times, 0.75), quantile(ro_times, 0.75), quantile(gz_times, 0.75))
)
df$iqr <- df$q3 - df$q1
df$q3 - df$q1

## plot
# barplot
g_latency_bars <- ggplot(df)+
  geom_bar(aes(x=test,y=med), fill=c("#ff0000", "#ff0000", "#0000ff"), stat="identity")+
  coord_flip()+
  labs(y="Median Latency (μs)")
g_latency_bars

# add points
df_points <- data.frame(
  times=c(rw_times, ro_times, gz_times),
  test=c(rep("readwrite", length(rw_times)), 
         rep('writeonly', length(ro_times)), 
         rep('zero', length(gz_times)))
  )
# for the sake of plotting, filter extreme outliers -- note that the stats don't change here.

df_points <- df_points[df_points$times<quantile(df_points$times, 0.99),]

df_points_subsample <- df_points[sample(1:nrow(df_points), nrow(df_points)/200),]

plot_theme <-  theme_minimal()+ theme(
  panel.grid.minor.x=element_blank(),
  panel.grid.major.y = element_blank(),
  axis.title.y=element_blank(),
  axis.text.y=element_text(margin=unit(c(0,-6,0,0), units='pt')),
  legend.position="none"
)

g_latency_points <- g_latency_bars + 
  geom_point(data=df_points_subsample, aes(x=test, y=times), 
             size=0.5, alpha=0.05,color="#000000", fill=NA,
             position=position_jitter(width=0.4,height=0))+
  plot_theme
g_latency_points


ggsave(here('code',"rendered_figures", 'gpio_latency_render.pdf'), plot=g_latency_points, width=4.1, height=1.3, units="in", useDingbats=FALSE)

# ------------------------------------
# roundtrip input/output latency

rt_python <- import(here('data', 'gpio_latency', 'roundtrip_python.csv'))
rt_script <- import(here('data', 'gpio_latency', 'roundtrip_pigs_script.csv'))
rt <- data.frame(
  latency = c(rt_python$latencies, rt_script$latencies),
  type = c(rep('python', nrow(rt_python)),
           rep('script', nrow(rt_script)))
) %>% filter(latency > 0)

rt_summary <- rt %>% group_by(type) %>%
  summarize(
    med=median(latency),
    q1 = quantile(latency, 0.25),
    q3 = quantile(latency, 0.75),
    iqr = q3-q1
  )

lat_python <- ggplot(rt_summary[rt_summary$type=="python",]) + 
  geom_bar(aes(x=type, y=med*1e6), stat="identity", fill="#ff0000")+
  geom_point(data=rt[rt$type=='python',], aes(x=type,y=latency*1e6),
             position=position_jitter(width=0.4, height=0),
             size=0.5, alpha=0.25,color="#000000", fill=NA)+
  labs(y="Latency (us)")+
  coord_flip()+plot_theme
lat_python

lat_script <- ggplot(rt_summary[rt_summary$type=="script",]) + 
  geom_bar(aes(x=type, y=med*1e9), stat="identity", fill="#0000ff")+
  geom_point(data=rt[rt$type=='script',], aes(x=type,y=latency*1e9),
             position=position_jitter(width=0.4, height=0),
             size=1, alpha=0.25,color="#000000", fill=NA)+
  labs(y="Latency (ns)")+
  coord_flip()+plot_theme
lat_script

ggsave(here('code',"rendered_figures", 'gpio_roundtrip_python.pdf'), plot=lat_python, width=4.1, height=0.8, units="in", useDingbats=FALSE)

ggsave(here('code',"rendered_figures", 'gpio_roundtrip_script.pdf'), plot=lat_script, width=4.1, height=0.8, units="in", useDingbats=FALSE)

# ------------
# density version

# filter one anomalous near-zero latency
rt <- rt[rt$latency>2e-07,]

calc_ribbon <- function(df, group){
  dens <- density(df$latency, na.rm=TRUE)
  dens_df <- data.frame(x=dens$x, y=dens$y)
  dens_df$y <- dens_df$y / max(dens_df$y)
  probs <- c(0.25, 0.5, 0.75)
  quantiles <- quantile(df$latency, prob=probs)
  dens_df$quant <- factor(findInterval(dens_df$x,quantiles))
  # add a single zero value so the line extends to zero (but doesnt affect stats)
  
  dens_df$group <- group$type
  
  return(dens_df)
}

df_ribbon <- rt %>% group_by(type) %>%
  group_modify(calc_ribbon) %>% ungroup()
df_ribbon$type <- df_ribbon$group

include_zero <- function(limits){
  return(c(0,limits[2]))
}

g_rt_density <- ggplot(rt)+
  geom_ribbon(data=df_ribbon, aes(x=x, y=y,ymin=0, ymax=y, fill=quant))+
  geom_line(data=df_ribbon, aes(x=x,y=y))+
  geom_point(aes(x=latency, y=-0.5*0.75),
             position=position_jitter(height=0.5*0.75, width=0),
             alpha=0.1, size=0.5)+
  scale_fill_manual(values=c("#ffcccc","#ffaaaa" ,"#ff6666" , "#ff0000"), guide="none")+
  # scale_x_continuous(limits=include_zero)+
  theme_minimal()+
  theme(
    plot.background = element_rect(fill="#ffffff"),
    panel.grid = element_blank(),
    axis.ticks.x = element_line(),
    axis.text.y=element_blank(),
    strip.background = element_blank(),
    strip.text = element_blank()
  )+
  labs(x="Latencies (ms)", y="density") + 
  facet_wrap(.~type, scales="free")
g_rt_density
ggsave(here('code',"rendered_figures","gpio_roundtrip_latency_density.pdf"), g_rt_density,
       width=4.1,height=1.25, units="in")


