
data {
  int<lower=0> n; // total number of data points
  int<lower=0> n_groups; // number of time periods (groups)
  int<lower=0> P; // number of predictors
  int<lower=1, upper=n_groups> g[n]; // group assignments
  
  matrix[n, P] X; // predictor matrix
  vector[P] beta_prior_means;

}

generated quantities{
  // Priors
  real sigma2 = inv_gamma_rng(1.5, 0.3);
  real<lower = 0> tau_alpha2 = inv_gamma_rng(1.5, 1);
  real<lower = 0> tau_beta2 = inv_gamma_rng(1.5, 1);
  real mu_alpha = normal_rng(50, 5); 
  vector[P] mu_beta;
  vector[n_groups] alpha;
  matrix[P, n_groups] beta;
  vector[n] y_pred;
  
  // prior samples of alpha
  for(t in 1:n_groups){
    alpha[t] = normal_rng(mu_alpha, sqrt(tau_alpha2));
  }

  // prior samples of beta
  for(p in 1:P){
      mu_beta[p] = normal_rng(beta_prior_means[p], 1);
    for(t in 1:n_groups){
      beta[p, t] = normal_rng(mu_beta[p], sqrt(tau_beta2));
    }
  }
  
  // prior predictive samples
  for(i in 1:n){
    y_pred[i] = normal_rng(alpha[g[i]] + X[i, ]*beta[, g[i]], sqrt(sigma2));
  }
  
}

