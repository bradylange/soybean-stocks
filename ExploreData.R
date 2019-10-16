rm(list=ls())
setwd("/home/ubuntu/Documents/Programming/R/Data")

library(ggplot2)
library(tidyr)
library(readr)
library(dplyr)
library(corrplot)


path_novice = '/home/ubuntu/Documents/MUDAC/MUDAC_2019_Fall/Data_Novice/'
path_undergraduate = '/home/ubuntu/Documents/MUDAC/MUDAC_2019_Fall/Data_Undergraduate/'

load_MUDAC_data = function(path, skip) {
    temp_data = read_csv(path, skip=skip)

    if('Date' %in% colnames(temp_data)) {
        temp_data = temp_data %>%
            separate(Date, c('Month', 'Day', 'Year')) %>%
            mutate(Month=as.numeric(Month), Day=as.numeric(Day), Year=as.numeric(Year))
    }

    return(temp_data)
}

data_novice = load_MUDAC_data(paste(path_novice, 'realmonthlycommodityexchangerates_1_.csv', sep=''), skip=11)
data_march = load_MUDAC_data(paste(path_undergraduate, 'ActiveSoybeanContractsForMarch2020.csv', sep=''), skip=3)
data_may = load_MUDAC_data(paste(path_undergraduate, 'ActiveSoybeanContractsForMay2020.csv', sep=''), skip=3)
data_july = load_MUDAC_data(paste(path_undergraduate, 'ActiveSoybeanContractsForJuly2020.csv', sep=''), skip=3)

pairs(data_march)
cor(data_march)

data_novice
pairs(data_march)
pairs(data_may)
pairs(data_july)
