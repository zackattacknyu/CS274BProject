data {
  int<lower=0> N; # number of data points
  int<lower=0> P; # number of predictors (including intercept)
  int<lower=0> m; # rows
  int<lower=0> k; # columns
  real<lower=0> tau;
  real<lower=0> c;
  int<lower=0,upper=1> y[m, k];
  matrix[m, k] temps; # predictors (including intercept)
}
transformed data {
  vector[N] x;
}
parameters {
  real beta0;
  real beta;
  real beta_cp;
  matrix[m, k] z;
}
model {
  matrix[m, k] lo;
  beta0 ~ normal(10, 5);
  beta ~ normal(-0.08, 1);
  for (i in 1:m) { # rows, m
    for (j in 1:k){ # columns, k
      # all the maxes and mins are for the boundary
        lo[i,j] <- beta0 + temps[i, j] * beta;
        z[i, j] ~ normal(
        (z[max(i-1, 1), j] + 
         z[min(i+1, m), j] + 
         z[i, max(j-1, 1)] + 
         z[i, min(j+1, k)]) / 4,
         
         1/(tau * 4 * c));
   
        y[i, j] ~ bernoulli_logit(lo[i, j] + z[i, j]);
    }
  }
}
generated quantities {
  matrix[m, k] p_rain;
  for (i in 1:m){
    for (j in 1:k){
      # generate predictions of rain
      p_rain[i, j] <- inv_logit(
        beta0 + temps[i, j] * beta + z[i, j]);
    }
  }
}