rm(list=ls())

library(ggplot2)
library(tidyr)
library(readr)
library(dplyr)
library(corrplot)
library(here)
library(readxl)
library(fmsb)
library(lmtest)

# Load the three soybean contract datasets
load_MUDAC_data = function(path, skip) {
    temp_data = read_excel(path, skip=skip)

    if('Date' %in% colnames(temp_data)) {
        temp_data = temp_data %>%
            separate(Date, c('year', 'month', 'day')) %>%
            mutate(month=as.numeric(month), day=as.numeric(day), year=as.numeric(year))
    }

    return(temp_data)
}
march = load_MUDAC_data(here('data', 'active_soybean_contracts_for_march_2020.xlsx'), skip=3)
may = load_MUDAC_data(here('data', 'active_soybean_contracts_for_may_2020.xlsx'), skip=3)
july = load_MUDAC_data(here('data', 'active_soybean_contracts_for_july_2020.xlsx'), skip=3)


# Load other datasets



# Lag stock closing prices in the contract datasets
add_prev_day_and_year = function(dataset) {
    temp = dataset %>%
                mutate(close_lag=lag(Close)) %>%
                mutate(year_prev=year-1)
    
    temp = temp %>%
                select(year, month, day, close_prev_year=Close) %>%
                inner_join(temp, by=c("year" = "year_prev", "month", "day")) %>%
                select(year = year.y, month, day, close=Close, close_lag, close_prev_year)

    return(temp)
}

march = add_prev_day_and_year(march)
may = add_prev_day_and_year(may)
july = add_prev_day_and_year(july)

write_csv(march, here("Modified Data", "march_clean.csv"))
write_csv(may, here("Modified Data", "may_clean.csv"))
write_csv(july, here("Modified Data", "july_clean.csv"))