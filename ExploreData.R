rm(list=ls())

library(ggplot2)
library(tidyr)
library(readr)
library(dplyr)
library(corrplot)
library(here)
library(readxl)

load_MUDAC_data = function(path, skip) {
    temp_data = read_excel(path, skip=skip)

    if('Date' %in% colnames(temp_data)) {
        temp_data = temp_data %>%
            separate(Date, c('Month', 'Day', 'Year')) %>%
            mutate(Month=as.numeric(Month), Day=as.numeric(Day), Year=as.numeric(Year))
    }

    return(temp_data)
}

novice = load_MUDAC_data(here('data', 'realmonthlycommodityexchangerates_1_.xls'), skip=11)
march = load_MUDAC_data(here('data', 'active_soybean_contracts_for_march_2020.xlsx'), skip=3)
may = load_MUDAC_data(here('data', 'active_soybean_contracts_for_may_2020.xlsx'), skip=3)
july = load_MUDAC_data(here('data', 'active_soybean_contracts_for_july_2020.xlsx'), skip=3)

pairs(march)
cor(march)

novice
pairs(march)
pairs(may)
pairs(july)
