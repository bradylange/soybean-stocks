# Developer: Brady Lange
# Date: 11/01/2019
# Description: MinneMUDAC Fall 2019 - farmer soybean stocks analysis.

# Set-up workspace
graphics.off()
rm(list = ls())
setwd("C:/Users/brady/Documents/r-projects/soybean-stocks")

# Load libraries
library(tidyverse)
library(readxl)
library(lmtest)
library(DAAG)
library(ISLR)
library(MASS)
library(fmsb)
library(leaps)

# Load and Explore Data
# =============================================================================
# Active soybean contracts for March of 2020
sbean_cont_mar <- read_excel(path = "./data/active_soybean_contracts_for_march_2020.xlsx", 
                             sheet = "ZS_H_2020.CSV", 
                             skip = 3) %>%
    arrange(., Date)
# Active soybean contracts for May of 2020
sbean_cont_may <- read_excel(path = "./data/active_soybean_contracts_for_may_2020.xlsx", 
                             sheet = "ZS_K_2020.CSV", 
                             skip = 3) %>%
    arrange(., Date)
# Active soybean contracts for July of 2020
sbean_cont_july <- read_excel(path = "./data/active_soybean_contracts_for_july_2020.xlsx", 
                              sheet = "ZS_N_2020.CSV", 
                              skip = 3) %>%
    arrange(., Date) 
# Active soybean contracts for March, May, and July of 2020 combined
sbean_cont_all <- rbind(sbean_cont_mar, sbean_cont_may, sbean_cont_july) %>%
    arrange(., Date)

# Separate dates into year, month, and day
sbean_cont_all <- sbean_cont_all %>%
    separate(., col = Date, into = c("Year", "Month", "Day"), sep = "-")
sbean_cont_all[1:3] <- sbean_cont_all[1:3] %>%
    factor(.)

# Convert dates to factors
sbean_cont_all[1:3] <- lapply(sbean_cont_all[1:3], factor)

# Convert March dates into factor
sbean_cont_mar$Date <- sbean_cont_mar$Date %>%
    factor(.) 
# Convert May dates into factor
sbean_cont_may$Date <- sbean_cont_may$Date %>%
    factor(.) 
# Convert July dates into factor
sbean_cont_july$Date <- sbean_cont_july$Date %>%
    factor(.) 
# Convert all dates into factor
sbean_cont_all$Date <- sbean_cont_all$Date %>%
    factor(.) 

# Explore data for March
print(head(sbean_cont_mar))
print(tail(sbean_cont_mar))
print(names(sbean_cont_mar))
# Explore data for May
print(head(sbean_cont_may))
print(tail(sbean_cont_may))
print(names(sbean_cont_may))
# Explore data for July
print(head(sbean_cont_july))
print(tail(sbean_cont_july))
print(names(sbean_cont_july))
# Explore data for all
print(head(sbean_cont_all))
print(tail(sbean_cont_all))
print(names(sbean_cont_all))

# Correlation Heatmap
plot(sbean_cont_all[1:5])
cor(sbean_cont_all[2:5])
cor_mat <- round(cor(sbean_cont_all[1:5]), 2)
head(cor_mat)
library(reshape2)
melted_cor_mat <- melt(cor_mat)
head(melted_cor_mat)
# Sets lower triangle to NA's
get_upper_tri <- function(cor_mat)
{
    cor_mat[lower.tri(cor_mat)] <- NA
    return(cor_mat)
}
upper_tri <- get_upper_tri(cor_mat)
melted_cor_mat <- melt(upper_tri, na.rm = T)
ggplot(data = melted_cor_mat, aes(Var2, Var1, fill = value)) +
    geom_tile(color = "white") +
    geom_text(aes(Var2, Var1, label = value), color = "black", size = 4) +
    scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                         midpoint = 0, limit = c(-1,1), space = "Lab", 
                         name="Pearson\nCorrelation") +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                     size = 12, hjust = 1)) +
    xlab("") +
    ylab("") +
    ggtitle("Correlation Matrix") +
    coord_fixed()

# Leaps
df <- as.data.frame(d)
leaps(x = df[ , 1:15], y = df[ , 16])

# Preprocess Data
# =============================================================================
# Filter out March days that didn't change - eliminate multicollinearity
sbean_cont_mar %>%
    filter(., Open != Close)
# Filter out May days that didn't change - eliminate multicollinearity
sbean_cont_may %>%
    filter(., Open != Close)
# Filter out July days that didn't change - eliminate multicollinearity
sbean_cont_july %>%
    filter(., Open != Close)
# Filter out all days that didn't change - eliminate multicollinearity
sbean_cont_all <- sbean_cont_all %>%
    filter(., Open != Close)
# Check if there are NA values
sbean_cont_all %>%
    filter(is.na(Date) || is.na(Open) || is.na(High) || is.na(Low) || is.na(Close))
library(imputeTS)
# Fill in NA values with mean
na_mean(sbean_cont_all)

# Analysis
# =============================================================================
# All Dates - March, May, and July
# -----------------------------------------------------------------------------
# All dates model
all_mod <- lm(Close ~ Date, data = sbean_cont_all)
summary(all_mod)
# VIF
VIF(all_mod)
# AIC
AIC(all_mod)
# BIC
BIC(all_mod)
# BP
bptest(all_mod)
# PRESS
press(all_mod)

# Shapiro tests
shapiro.test(sbean_cont_all$Open)
shapiro.test(sbean_cont_all$High)
shapiro.test(sbean_cont_all$Low)
shapiro.test(sbean_cont_all$Close)

# Step AIC - find the best model
stepAIC(all_mod, direction = "both")

# Best model
b_all_mod <- lm( ~ , data = sbean_cont_all)
summary(b_all_mod)

# Transform model
trans_all_mod <- lm(I(log(Close)) ~ , data = d)
summary(trans_all_mod)
bptest(trans_all_mod) 
VIF(trans_all_mod)
# AIC
AIC(trans_all_mod)
# BIC
BIC(trans_all_mod)
# PRESS
press(trans_all_mod)

# Correlation Heatmap
cor_mat <- round(cor(b_all_mod), 2)
melted_cor_mat <- melt(cor_mat)
upper_tri <- get_upper_tri(cor_mat)
melted_cor_mat <- melt(upper_tri, na.rm = T)
ggplot(data = melted_cor_mat, aes(Var2, Var1, fill = value)) +
    geom_tile(color = "white") +
    geom_text(aes(Var2, Var1, label = value), color = "black", size = 4) +
    scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                         midpoint = 0, limit = c(-1,1), space = "Lab", 
                         name="Pearson\nCorrelation") +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                     size = 12, hjust = 1)) +
    xlab("") +
    ylab("") +
    ggtitle("All Dates - Correlation Matrix") +
    coord_fixed()

melt_d <- melt(b_all_mod, id.vars = "All Dates")
ggplot(melt_d) + 
    geom_point(aes(value, Nitrate, color = variable)) + 
    geom_smooth(aes(value, Nitrate, color = variable), method = "lm") +
    facet_wrap(~variable, scales = "free_x") 