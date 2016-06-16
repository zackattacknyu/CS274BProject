data {
  int<lower=0> m; # rows
  int<lower=0> k; # columns
  int<lower=0,upper=1> y[m, k];
  matrix[m, k] temps; # predictors (including intercept)
}
parameters {
  real beta0;
  real beta;
  real betarain;
  real betarain2;
  real<lower=0> tau;
  real<lower=0> sigma;
  matrix[m, k] z;
}
model {
 # real lsd;
#  real cloudy;
  matrix[m, k] lo;
  beta0 ~ normal(0, 10);
  beta ~ normal(0, 5);
  betarain ~ normal(-5, 1);
  betarain2 ~ normal(-2, 1);
#  for (i in 1:m) { # rows, m
#    for (j in 1:k){
#      z[i, j] ~ normal(0, 2);
#    }
#  }
  #beta_sd ~ normal(0, 2);
  tau ~ gamma(2, 2); # was 1, 2
  sigma ~ gamma(1, 1);
  for (i in 1:m) { # rows, m
    for (j in 1:k){ # columns, k
      # all the maxes and mins are for the boundary
      #  lsd <- sd(to_vector(z[max(i-1, 1):min(i+1, m),max(j-1, 1):min(j+1, k)]));
        lo[i,j] <- beta0 + temps[i, j] * beta;
        z[i, j] ~ normal(
        (z[max(i-1, 1), j] + 
         z[min(i+1, m), j] + 
         z[i, max(j-1, 1)] + 
         z[i, min(j+1, k)]) / 4,
         sigma + 1 / (tau * 4));
        
        y[i, j] ~ bernoulli(
          inv_logit(lo[i, j] + z[i, j])* 
          inv_logit(betarain + betarain2 * temps[i, j]));
    }
  }
}
generated quantities {
  matrix[m, k] p_rain;
  for (i in 1:m){
    for (j in 1:k){
      # generate predictions of rain
      p_rain[i, j] <- inv_logit(
        beta0 + temps[i, j] * beta + z[i, j]) * 
        inv_logit(betarain + betarain2 * temps[i, j]);
    }
  }
}