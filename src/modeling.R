library(rstan)
library(tidyverse)

setwd("~./STAT775/Project")
source("./src/load.R")

prior_predictive_sims = FALSE
posterior_sims = TRUE
standardize = FALSE 


##########################
# ----- Data Prep ----- #
#########################

data = load_spotify_data()
# Select predictors
X = data %>% select(artist_pop, track_loudness, 
                    track_danceability, track_speechiness, 
                    track_tempo, track_valence,
                    track_instrumentalness, track_acousticness,
                    track_liveness, track_duration)
# Prior mean of each predictor's coefficient distribution
beta_prior_means=c(0.1, 0.1, 0.1, 0.1, 0.1, 0.1, -0.1, -0.1, -0.1, -0.1)
P = ncol(X)

# Select response 
y = data %>% select(track_pop) %>% pull(track_pop)
n = length(y)

# Define group association
g = data %>% pull(release_decade) # group identifier for each observation
n_groups = length(unique(g)) # number of time period groups

if(standardize==TRUE){
  y_mean = mean(Y)
  y_sd = sd(Y)
  X = X %>% mutate(across(where(is.numeric), scale, center=TRUE))
  y = (y - y_mean)/y_sd
}


run_prior_pred = function(stan_file="prior_predictive.stan", 
                          fit_file="./models/prior_fit.rds",
                          summary_file="./models/prior_fit_summary.txt"){
  
  cat("Compiling and simulating prior model...")
  # Fit the model
  prior_model = stan_model(file=stan_file)
  prior_fit = sampling(object=prior_model, algorithm="Fixed_param",
                       data=list(n=n, n_groups=n_groups, g=g, P=P, y=y, X=X,
                                 beta_prior_means=beta_prior_means))
  # Save fit object to disk
  prior_fit@stanmodel@dso = new("cxxdso")
  saveRDS(prior_fit, file=fit_file)
  # Save summary to disk 
  prior_summary = as.data.frame(summary(prior_fit)[[1]])
  dput(prior_summary, file=summary_file, control="all")

  cat("Done.\n")
}

if(prior_predictive_sims==TRUE){run_prior_pred()}



run_posterior = function(stan_file="posterior.stan", 
                         fit_file="./models/post_fit.rds",
                         summary_file="./models/post_fit_summary.txt"){
  
  cat("Compiling and simulating posterior model...")
  post_model = stan_model(file=stan_file)
  my_data = list(n=n, n_groups=n_groups, g=g, P=P, y=y, X=X,
                 beta_prior_means=beta_prior_means)
  post_fit = sampling(object=post_model, data=my_data)

  # Save fit object to disk
  post_fit@stanmodel@dso = new("cxxdso")
  saveRDS(post_fit, file=fit_file)
  # Save summary to disk 
  post_summary = as.data.frame(summary(post_fit)[[1]])
  dput(post_summary, file=summary_file, control="all")
  
  cat("Done.\n")
}

if(posterior_sims==TRUE){run_posterior()}
