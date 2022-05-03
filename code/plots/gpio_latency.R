library(ggplot2)
library(rio)
library(here)
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
  theme_minimal()+
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

g_latency_points <- g_latency_bars + 
  geom_point(data=df_points_subsample, aes(x=test, y=times), 
             size=0.5, alpha=0.05,color="#000000", fill=NA,
             position=position_jitter(width=0.4,height=0))+
  theme(
    panel.grid.minor.x=element_blank(),
    panel.grid.major.y = element_blank(),
    axis.title.y=element_blank(),
    axis.text.y=element_text(margin=unit(c(0,-6,0,0), units='pt')),
    legend.position="none"
  )
g_latency_points


ggsave(here('code',"rendered_figures", 'gpio_latency_render.pdf'), plot=g_latency_points, width=4.1, height=1.3, units="in", useDingbats=FALSE)
warnings()

