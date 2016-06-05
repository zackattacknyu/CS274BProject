library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


N <- length(rain_occ)
#N <- 100000
stan.data <- list(N=N,
                  P=2,
                  y=matrix(rain_occ, nrow=nrow(temps)),
                  m=nrow(temps),
                  k=ncol(temps),
                  tau=40,
                  c=1,
                  temps=temps)

stan.data <- list(N=N,
                  P=2,
                  y=test.rain_occ,
                  m=nrow(temps),
                  k=ncol(temps),
                  tau=30,
                  c=1,
                  temps=(test.temps-mean(test.temps))/sd(test.temps))

model <- stan_model(file="lr.stan")
fit <- optimizing(model, data=stan.data, verbose=TRUE, iter=100)

## map of latent variable
## look at histograms, etc, of model fit
image(matrix(fit$par[4:(N+3)], nrow = 500))
hist(matrix(fit$par[4:(N+3)], nrow = 500))
image(test.temps)
image(matrix(fit$par[(N+4):(2*N+3)], nrow = 500))
image(test.rain_occ)

hist(matrix(fit$par[(N+3):(2*N+2)], nrow = 500))

fit$par[1:3]