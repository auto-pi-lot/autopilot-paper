library(rio)
library(tidyverse)
library(sitools)
library(here)

base_dir <- here('data', 'network_tests')
files <- list.files(base_dir)

# load data n clean
data <- bind_rows(lapply(paste0(base_dir, files), import), .id='test')
data$payload <- nchar(data$payload, 'bytes')
data[is.na(data$payload),]$payload <- 0

data$throughput <- data$actual_rate * data$payload

#data <- data[!(data$test %in% c(2, 5,6,  7, 9)),]

data$payload_text <- scales::number_bytes(data$payload)

ggplot(data, aes(y=throughput, x=actual_rate, color=payload_text))+
  geom_point()+
  labs(color="Message Payload", x="Message rate (Hz)")+
  scale_y_continuous("Throughput", labels=scales::number_bytes)
  #scale_x_log10()

data[data$mean_delay<0,]$mean_delay <- 0.000001


less_data <- data[!(data$test %in% c(2, 5,6,  7, 9)),]
ggplot(less_data, aes(y=mean_delay, x=actual_rate, color=as.factor(payload)))+
  geom_point()+
  labs(color="Message Payload", x="Message rate (Hz)")+
  scale_x_log10()+
  scale_y_log10()
