library(dplyr)
library(readr)

load_spotify_data = function(file="./data/playlist_data.csv"){
    data = read_csv(file, col_types=cols()) %>% 
    select(-X1) %>%
    filter(track_pop > 5, track_danceability != 0,
           track_loudness != 0, track_speechiness != 0,
           track_valence != 0) %>% 
    mutate(playlist_name=ifelse(is.na(playlist_name), 
                                "Top Hits of 2021", 
                                playlist_name),
           release_year=as.numeric(str_sub(playlist_name, -4, -1)),
           release_decade=case_when(
             1970 <= release_year & release_year <= 1979 ~ 1,
             1980 <= release_year & release_year <= 1989 ~ 2,
             1990 <= release_year & release_year <= 1999 ~ 3,
             2000 <= release_year & release_year <= 2009 ~ 4,
             2010 <= release_year & release_year <= 2019 ~ 5,
             2020 <= release_year & release_year <= 2029 ~ 6
           ),
           genre_simplified=case_when(
             str_detect(artist_genres_string, "pop") & 
             !str_detect(artist_genres_string, "rock") ~ "pop",
             str_detect(artist_genres_string, "rock|metal") ~ "rock",
             str_detect(artist_genres_string, "latin") ~ "latin",
             str_detect(artist_genres_string, "hip hop|rap") ~ "hip hop",
             str_detect(artist_genres_string, "soul|r&b") ~ "soul/r&b",
             str_detect(artist_genres_string, "folk|country|western") ~"folk/country",
             TRUE ~ "other"
           ),
           pop_indicator=ifelse(genre_simplified=="pop", 1, 0),
           track_duration=track_duration/60000 # ms to minutes
           )
  
  return(data)
  
}

# Load a fitted model from saved file
load_model = function(fit_file, summary_file){
  cat("Loading files...")
  fit = readRDS(fit_file)
  samples = rstan::extract(object=fit, pars = c("alpha", "beta", "sigma2"))
  alpha_samples = samples[["alpha"]]
  beta_samples = samples[["beta"]]
  sigma_samples = samples[["sigma2"]]
  summary = dget(summary_file)
  cat("Done.\n")
  return(list(summary, alpha_samples, beta_samples, sigma_samples))
}

  


