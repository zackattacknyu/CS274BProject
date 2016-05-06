library(ngspatial)
library(R.matlab)
library(ggplot2)

## TODO handle date -> string conversion
## format is YYMMDDHHMM

rain <- readMat("projectData/ytarget1109120545.mat")$ytarget
rain[rain==-999.9] <- NA
rain_occ <- as.integer(rain > 0)


temps <- readMat("projectData/xone1109120545.mat")$xone

## baseline model: LR
lr.df <- data.frame(rain_occ=as.vector(rain_occ),
                    temps = as.vector(temps))
lr.model <- glm(rain_occ ~ temps, family="binomial", data=lr.df)

## test on next hour
test.temps <- readMat("projectData/xone1109120645.mat")$xone

test.rain <- readMat("projectData/ytarget1109120645.mat")$ytarget
M <- 500 # rows
N <- 750 # columns
test.rain[test.rain==-999.9] <- NA
test.rain_occ <- as.integer(test.rain > 0)

test.df <- data.frame(rain=as.vector(test.rain_occ),
                      temps=as.vector(test.temps))
test.df$preds <- predict(lr.model, data.frame(temps=as.vector(test.temps)),
                 type="response")

ggplot(test.df[sample(1:nrow(test.df), 2*10^3),], aes(temps, preds)) + 
  geom_point(alpha=0.5) + facet_grid(rain~.) + geom_hline(yintercept = 0.5)

ggplot(test.df, aes(preds)) + geom_histogram() +
  facet_grid(rain~., scales = "free_y") + geom_vline(xintercept = 0.5)

## try autologistic
A <- adjacency.matrix(M, N) # fails! this package sucks.
autologistic(rain_occ ~ temps, lr.df, A)