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

# March Contract Date
close = march$close
close_lag = march$close_lag
close_prev_year = march$close_prev_year
year = march$year
month = march$month
day = march$day
pairs(~close+close_lag+close_prev_year+year+month+day)

# Base Model
reg_march = lm(close ~ close_lag + close_prev_year + year + month + day)
e = residuals(reg_march)
shapiro.test(e) # Passes
bptest(reg_march) # Fails
VIF(reg_march) # Fails
summary(reg_march) # Passes

# Removed Day
reg_march = lm(close ~ close_lag + close_prev_year + year + month)
e = residuals(reg_march)
shapiro.test(e) # Passes
bptest(reg_march) # Fails
VIF(reg_march) # Fails
cor(close_lag, close_prev_year)
cor(close_lag, year)
cor(close_lag, month)
cor(close_prev_year, year)
cor(close_prev_year, month)
cor(year, month) # Fails
summary(reg_march) # Passes

# Removed year
reg_march = lm(close ~ close_lag + close_prev_year + month)
e = residuals(reg_march)
shapiro.test(e) # Passes
bptest(reg_march) # Fails
VIF(reg_march) # Fails
summary(reg_march) # Passes

# Added year and removed close_lag
pairs(~close+close_prev_year+year+month)
reg_march = lm(close ~ close_prev_year + year + month)
e = residuals(reg_march)
shapiro.test(e) # Fails
bptest(reg_march) # Fails
VIF(reg_march) # Passes
summary(reg_march) # Passes

# Tried log(close)
close_log = log(close)
pairs(~close_log+close_prev_year+year+month)
reg_march = lm(close_log ~ close_prev_year + year + month)
e = residuals(reg_march)
shapiro.test(e) # Fails
bptest(reg_march) # Fails
VIF(reg_march) # Passes
summary(reg_march) # Passes

# Tried log(month)
month_log = log(month)
pairs(~close+close_prev_year+year+month_log)
reg_march = lm(close ~ close_prev_year + year + month_log)
e = residuals(reg_march)
shapiro.test(e) # Fails
bptest(reg_march) # Fails
VIF(reg_march) # Passes
summary(reg_march) # Passes

# Tried log(month)
close_prev_year_log = log(close_prev_year)
pairs(~close+close_prev_year_log+year+month)
reg_march = lm(close ~ close_prev_year_log + year + month)
e = residuals(reg_march)
shapiro.test(e) # Fails
bptest(reg_march) # Fails
VIF(reg_march) # Passes
summary(reg_march) # Passes

# Removed year
pairs(~close+close_prev_year+month)
reg_march = lm(close ~ close_prev_year + month)
e = residuals(reg_march)
shapiro.test(e) # Fails
bptest(reg_march) # Passes
VIF(reg_march) # Passes
summary(reg_march) # Passes

# Removed month
pairs(~close+close_prev_year)
reg_march = lm(close ~ close_prev_year)
e = residuals(reg_march)
shapiro.test(e) # Fails
bptest(reg_march) # Passes
VIF(reg_march) # Passes
summary(reg_march) # Passes

# Transform close_prev_year
plot(close_prev_year, close)
close_transformed = 
plot(close_prev_year, close_transformed)
