library(ngspatial)
library(R.matlab)
library(ggplot2)

rain.day <- function(timestr){
  rain <- readMat(paste0("projectData/ytarget", timestr, ".mat"))$ytarget
  rain[rain==-999.9] <- 0
  rain_occ <- rain > 0
  storage.mode(rain_occ) <- "integer"
  rain_occ
}

temps.day <- function(timestr){
  temps <- readMat(paste0("projectData/xone", timestr,".mat"))$xone
  temps <- (temps - mean(temps))/sd(temps)
  temps
}


test.ts <- c(
  "1209071815",
  "1209270615",
  "1209280115",
  "1209050545",
  "1209062145",
  "1209282315",
  "1209290045")

## common testing parameters

train.ts <- "1109120545"
## train & test baseline model
lr.df <- data.frame(rain_occ=as.vector(rain.day(train.ts)),
                    temps = as.vector(temps.day(train.ts)))

lr.model <- glm(rain_occ ~ temps,
                family="binomial", data=lr.df)

#test.lr.df <- data.frame(rain_occ=as.vector(rain.day(test.ts[1])),
#                         temps = as.vector(temps.day(test.ts[1])))

test.lr.df <- data.frame(rain_occ=as.vector(rain.day(train.ts)),
                         temps = as.vector(temps.day(train.ts)))

test.lr.df$predictions <- predict(lr.model, test.lr.df, type="response")
#image(matrix(predict(lr.model, test.lr.df), nrow=500))
#image(matrix((predict(lr.model, test.lr.df) > 0.5) == test.lr.df$rain_occ, nrow=500))
## Overall performance
mean(test.lr.df$rain_occ)
mean(test.lr.df$predictions>0.5)
p.t <- 0.2
## Choose cutoff of 0.2 to match overall rain rate.
## given rain occurred, what is the prob that LR detected it?
## sensitivity
rs <- subset(test.lr.df, rain_occ==1)
mean(rs$predictions > 0.2) # 42%

## specificity
rs <- subset(test.lr.df, rain_occ==0)
mean(rs$predictions < 0.2) # 98%


## train baseline LR-CRF model
stan.data <- list(y=matrix(rain.day(train.ts), nrow=500),
                  m=500,
                  k=750,
                  temps=temps.day(train.ts)
                  #test_temps=temps.day(test.ts[1])
                  )

model <- stan_model(file="CS274BProject/R/lr.stan")

fit <- optimizing(model, data=stan.data, verbose=TRUE, iter=100)



lr.crf <- fit$par[1:3]
zs <- matrix(fit$par[4:(3+500*750)], nrow=500)
ps <- matrix(fit$par[(4+500*750):length(fit$par)], nrow=500)



p.diff <- melt(ps-predict(lr.model, data.frame(temps=as.vector(temps.day(train.ts))),
                 type="response"))

#st.ov <- read.table("CS274BProject/projectDataInfo/us_states_outl_ug.tmp")
#names(st.ov) <- c("Var1", "Var2")
ps <- matrix(fit$par[(4+500*750):length(fit$par)], nrow=500)
rownames(ps) <- seq.int(-130, -100, length.out=500)
colnames(ps) <- seq.int(25, 45, length.out=750)

states <- map_data("state")
mmm <- melt(ps)
names(mmm) <- c("long", "lat", "p.rain")
ggplot(mmm, aes(long, lat)) + geom_raster(aes(fill=p.rain)) +
  geom_polygon(aes(x=long, y=lat, group = group), colour="black", alpha=0.0, data=states) +
  coord_fixed(xlim=c(-130, -100), ylim=c(25, 45), ratio=1) + 
  scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0)) +
  labs(x="Longitude", y="Latitude", fill="Probability\nof rain")
ggsave("~/class/274b/CS274BProject/R/prec.png", width=6, height=3)

#long :-130, -100
# lat:25, 45

mean(ps>0.5)
mean(ps>0.2)
mean(rain.day(train.ts))
mean((ps * stan.data$y) > 0.5)
mean((ps * stan.data$y) > 0.2)
## image(zs)


## evaluate on test data
## Fancy model
w.model <- stan_model(file="CS274BProject/R/lr_w.stan")
w.fit <- optimizing(w.model, data=stan.data, verbose=TRUE, iter=100)

w.ps <- matrix(w.fit$par[(7+500*750):length(w.fit$par)], nrow=500)
rownames(w.ps) <- seq.int(-130, -100, length.out=500)
colnames(w.ps) <- seq.int(25, 45, length.out=750)

w.zs <- matrix(w.fit$par[6:(5+500*750)], nrow=500)
image(w.zs)
#image(stan.data$temps)
w.fit$par[1:6]
#states <- map_data("state")
w.mmm <- melt(w.ps)

names(w.mmm) <- c("long", "lat", "p.rain")
ggplot(w.mmm, aes(long, lat)) + geom_raster(aes(fill=p.rain)) +
  geom_polygon(aes(x=long, y=lat, group = group), colour="black", alpha=0.0, data=states) +
  coord_fixed(xlim=c(-130, -100), ylim=c(25, 45), ratio=1) + 
  scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0)) +
  labs(x="Longitude", y="Latitude", fill="Probability\nof rain")

r.tmp <- rain.day(train.ts)
rownames(r.tmp) <- seq.int(-130, -100, length.out=500)
colnames(r.tmp) <- seq.int(25, 45, length.out=750)
r.mmm <- melt(r.tmp)
names(r.mmm) <- c("long", "lat", "rain")


ggplot(r.mmm, aes(long, lat)) + geom_raster(aes(fill=rain)) +
  geom_polygon(aes(x=long, y=lat, group = group), colour="black", alpha=0.0, data=states) +
  coord_fixed(xlim=c(-130, -100), ylim=c(25, 45), ratio=1)+ 
  scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0)) +
  labs(x="Longitude", y="Latitude", fill="Rain\nindicator")
ggsave("~/class/274b/CS274BProject/R/prec_t.png", width=6, height=3)
#ggsave("~/class/274b/CS274BProject/R/prec_w.png", width=6, height=3)


mean(w.ps>0.5)
mean(w.ps>0.2)
pss <- rbind(pss, c(w.fit$par[1:5], mean(w.ps>0.5)))



for (i in 1:40){
  w.fit <- optimizing(w.model, data=stan.data, verbose=TRUE, iter=100)
  w.ps <- matrix(w.fit$par[(7+500*750):length(w.fit$par)], nrow=500)
  pss2 <- rbind(pss2, c(w.fit$par[1:5], mean(w.ps>0.5)))
  if (mean(w.ps>0.5) > 0.03)
    good.fit <- w.fit
}

mean(rain.day(train.ts))
sum((w.ps * stan.data$y) > 0.5) / sum(stan.data$y)
sum((test.lr.df$predictions * stan.data$y) > 0.5) / sum(stan.data$y)
sum((ps * stan.data$y) > 0.5) / sum(stan.data$y)

ggplot(pss2, aes(tau, pr)) + geom_point() + scale_x_log10()
## tau, mean rain
#pss2 <- as.data.frame(t(w.fit$par[1:5]))
#pss2$pr <- mean(w.ps>0.5)

mean((w.ps * stan.data$y) > 0.2)

## Good parameters

## Bad parameters
## tau ~ G(1, 1)
no.rain <- abs(stan.data$y-1)
## create tex table of results
summ.stats <- data.frame(
  Model=c("LR", "LR-CRF", "LR-CRF+"),
  "Overall rain proportion"=c(mean(test.lr.df$predictions>0.5),
                                 mean(ps>0.5),
                                 mean(w.ps>0.5)),
  "Sensitivity"=c(sum((test.lr.df$predictions * stan.data$y) > 0.5) / sum(stan.data$y),
                                 sum((ps * stan.data$y) > 0.5) / sum(stan.data$y),
                                 sum((w.ps * stan.data$y) > 0.5) / sum(stan.data$y)),
  "Specificity"=c(sum((test.lr.df$predictions * no.rain) < 0.5 & (test.lr.df$predictions * no.rain) > 0) / sum(no.rain),
                  sum((ps * no.rain) < 0.5 & (ps * no.rain) > 0) / sum(no.rain),
                  sum((w.ps * no.rain) < 0.5 & (w.ps * no.rain) > 0) / sum(no.rain)))

print(xtable(summ.stats, digits = 3), include.rownames=FALSE)
