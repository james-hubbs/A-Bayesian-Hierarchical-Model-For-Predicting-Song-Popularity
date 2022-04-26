
data {
  int<lower=0> n; // total number of data points
  int<lower=0> n_groups; // number of time periods (groups)
  int<lower=0> P; // number of predictors
  int<lower=1, upper=n_groups> g[n]; // group assignments
  
  vector[n] y; // response
  matrix[n, P] X; // predictor matrix
  vector[P] beta_prior_means;

}

parameters {
  vector[n_groups] alpha; // intercept for each of the T groups
  matrix[P, n_groups] beta; // we have P predictors within each of T groups
  real<lower = 0> sigma2; // residual variance
  
  real mu_alpha; // mean of intercept distribution
  real<lower = 0> tau_alpha2; // variance of intercept distribution
  
  vector[P] mu_beta; // means of each of the p coefficient's distributions
  vector<lower=0>[P] tau_beta2; // variances of each of the p coefficient's distributions

}

transformed parameters{
  real<lower = 0> sigma;
  real<lower = 0> tau_alpha;
  vector<lower=0>[P] tau_beta;
  
  tau_alpha = sqrt(tau_alpha2);
  sigma = sqrt(sigma2);
  tau_beta = sqrt(tau_beta2);
}

model {
  // Priors
  sigma2 ~ inv_gamma(1.5, 0.3);
  tau_alpha2 ~ inv_gamma(1.5, 1);
  tau_beta2 ~ inv_gamma(1.5, 1);
  mu_alpha ~ normal(50, 5);
  
  for(t in 1:n_groups){
    alpha[t] ~ normal(mu_alpha, tau_alpha);
  }
  
  for(p in 1:P){
      mu_beta[p] ~ normal(beta_prior_means[p], 1);
    for(t in 1:n_groups){
      beta[p, t] ~ normal(mu_beta[p], tau_beta);
    }
  }
  
  for(i in 1:n){
    y[i] ~ normal(alpha[g[i]] + X[i, ]*beta[, g[i]], sigma);
  }
  
}


generated quantities{
  // prior predictive samples
  // real alpha_prior = normal_rng()
  // real beta_prior = 
  // real<lower = 0> sigma;
  // sigma = y_sd * std_sigma;
  
  // posterior predictive samples?
  vector[n] y_pred;
  for(i in 1:n){
    y_pred[i] = normal_rng(alpha[g[i]] + X[i, ]*beta[, g[i]], sigma);
  }
}

