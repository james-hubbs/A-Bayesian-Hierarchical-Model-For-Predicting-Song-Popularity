library(tidyverse)
library(reshape2)
library(GGally)

setwd("~/STAT775/Project")
source("load.R")

  # Load data and models
data = load_spotify_data()
prior_model = load_model("./models/prior_fit.rds", "./models/prior_fit_summary.txt")
prior_summary = prior_model[[1]]

post_model = load_model("./models/post_fit.rds", "./models/post_fit_summary.txt")
post_summary = post_model[[1]]

# Load standardized summary model, to compare coefficients
post_summary_stand = dget("./models/post_summary_standardized.txt")

# Todo: 
#  - standardized coefficient plot
#  - something with beta samples (full dist)?


##############################
# Track Popularity by Decade #
#############################
ggplot(data, aes(y=track_pop, x=as.factor(release_decade))) +      
  geom_boxplot(color="#c5050c") + theme_bw() +
  xlab("\nDecade") + ylab("Track Popularity\n") + 
  scale_x_discrete(labels=c("70s", "80s", "90s", "00s", "10s", "20s")) +
  ggtitle("Track Popularity by Decade", subtitle="1970-2021") +
  theme(plot.title=element_text(face="bold", size=20), 
        axis.title=element_text(size=12, color="black"),
        plot.subtitle=element_text(size=12, face="plain", color="black"),
        axis.text=element_text(color="black"))
ggsave("./plots/track_pop_decade.png", height=5, width=7)


# data_by_artist = data %>% 
#   select(artist_name, track_pop, artist_pop, track_loudness, 
#         track_danceability, track_speechiness, 
#         track_tempo, track_valence,
#         track_instrumentalness, track_acousticness,
#         track_liveness, track_duration) %>% 
#   group_by(artist_name) %>% 
#   summarise_all(mean)
       


#####################
# Predictor Trends #
###################
trends_data = data %>% select(release_year, artist_pop, track_loudness, 
                         track_danceability, track_speechiness, 
                         track_tempo, track_valence,
                         track_instrumentalness, track_acousticness,
                         track_liveness, track_duration) %>% 
  group_by(release_year) %>% summarize_all(mean)


for(var in c("track_loudness", 
             "track_danceability", "track_speechiness", 
             "track_tempo", "track_valence",
             "track_instrumentalness", "track_acousticness",
             "track_liveness", "track_duration")){
  
  var_formatted = str_to_title(str_split(var, "_")[[1]][2])
  print(ggplot(trends_data, aes_string(x="release_year", y=var)) + 
    geom_line(alpha=0.8, color="#646569") + 
    geom_point(alpha=0.8, color="#646569") + 
    geom_smooth(method="loess", formula="y~x", color="#c5050c", se=FALSE, size=1.1) +
    theme_bw() + ggtitle(paste("Average", var_formatted, "By Year"), 
                         subtitle="1970-2021") +
    theme(plot.title=element_text(face="bold", size=20), 
          axis.title=element_text(size=12, color="black"),
          plot.subtitle=element_text(size=12, face="plain", color="black"),
          axis.text=element_text(color="black")) +
    xlab("\nYear") + ylab(paste("Average", var_formatted, "\n")))
  ggsave(paste("./plots/", var, "_trend_.png", sep=""), height=5, width=7)
  
}

##########################
# Predictor Correlations #
#########################

predictors = data %>% 
  select(track_loudness, 
         track_danceability, track_speechiness, 
         track_tempo, track_valence,
         track_instrumentalness, track_acousticness,
         track_liveness, track_duration) %>% 
  rename("Loudness"=track_loudness, 
         "Danceability"=track_danceability,"Speechiness"=track_speechiness,
         "Tempo"=track_tempo, "Valence"=track_valence, 
         "Instrumentalness"=track_instrumentalness,  "Acousticness"=track_acousticness, 
         "Liveness"=track_liveness, "Duration"=track_duration)

corrs = cor(predictors)
rm(predictors)
corrs[lower.tri(corrs)] = NA
corrs = melt(corrs, na.rm=TRUE) %>% filter(value != 1)
ggplot(corrs, aes(Var2, Var1, fill=value))+
  geom_tile(color="white")+
  geom_text(size=2.5, aes(label=round(value, 1))) +
  scale_fill_gradient2(low="#c5050c", high="green", mid="white", 
                       midpoint=0, limit=c(-1,1), space="Lab", 
                       name="") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=45, vjust=1, size=12, hjust=1, color="black"), 
        axis.text.y=element_text(vjust = 1, size=12, hjust=1, color="black"), 
        title=element_text(face="bold", size=18)) +
  coord_fixed() + 
  xlab("") + ylab("") + ggtitle("Predictor\nCorrelations")
ggsave("./plots/predictor_correlations.png", height=5, width=7)

####################################################
# Predictor Correlations With Response (Track Pop) #
###################################################
predictors2 = data %>%
  select(track_pop, artist_pop, track_loudness, 
         track_danceability, track_speechiness, 
         track_tempo, track_valence,
         track_instrumentalness, track_acousticness,
         track_liveness, track_duration) %>% 
  rename("Popularity"=track_pop, "Artist Popularity"=artist_pop, 
         "Loudness"=track_loudness,"Danceability"=track_danceability,  
         "Speechiness"=track_speechiness, "Tempo"=track_tempo,
         "Valence"=track_valence,"Instrumentalness"=track_instrumentalness,
         "Acousticness"=track_acousticness, "Liveness"=track_liveness, 
         "Duration"=track_duration)

corrs = cor(predictors2)
rm(predictors2)
corrs = melt(corrs, na.rm=TRUE)
corrs_with_pop = corrs %>% 
  filter(Var1=="Popularity" & Var2 != "Popularity") %>% 
  mutate(abs_value = abs(value)) %>% slice_max(abs_value, n=10) %>%  
  arrange(desc(value))

ggplot(corrs_with_pop, aes(x=Var2, y=value)) + 
  geom_col(fill="#c5050c", color="#282728") +
  geom_hline(yintercept=0, color="black") +
  scale_x_discrete(limits=corrs_with_pop %>% pull(Var2)) +
  scale_y_continuous(limits=c(-0.2, 0.6), breaks=seq(-0.2, 0.6, 0.1)) +
  theme_bw() +
  theme(title=element_text(face="bold"), axis.text=element_text(face="bold")) +
  xlab("") + ylab("") +
  ggtitle("Predictor Correlation with Track Popularity") +
  theme(plot.title=element_text(face="bold", size=20), 
        axis.title=element_text(size=12, color="black"),
        plot.subtitle=element_text(size=12, face="plain", color="black"),
        axis.text.x=element_text(color="black", vjust=.7, angle=20),
        axis.text.y=element_text(color="black"))
ggsave("./plots/predictor_correlation_w_pop.png", height=5, width=7)
 

#########################
# Prior Predictive Plot #
#########################
prior_predictions = as.data.frame(t(prior_summary)) %>% 
  select(contains("y_pred")) %>% 
  slice_head() %>% 
  pivot_longer(cols=contains("y_pred"), values_to="y_pred")
prior_predictions$track_pop = data$track_pop

# Convert wide to long
prior_predictions = prior_predictions %>% select(track_pop, y_pred) %>% 
  mutate(index = row_number()) %>% 
  pivot_longer(cols=c("track_pop", "y_pred"), names_to="y") %>% 
  mutate(y = ifelse(y=="track_pop", "Observed", "Predicted"))

ggplot(prior_predictions, aes(linetype=y)) + 
  geom_density(aes(x=value), color="#c5050c", size=1.01, key_glyph=draw_key_path) + 
  theme_bw() +
  ggtitle("Prior Predictions") +
  xlab("\nTrack Popularity")+
  ylab("Density\n") +
  labs(linetype="", caption="") +
  theme(plot.title=element_text(face="bold", size=20), 
        axis.title=element_text(size=12),
        plot.subtitle=element_text(size=8, face="plain", color="black"),
        legend.position="top", legend.justification='left', 
        legend.text=element_text(size=14),
        axis.text=element_text(color="black"))
ggsave("./plots/prior_predictions.png", height=5, width=7)

##############################
# Posterior Predictive Plot #
#############################

# Add mean posterior predictive values to the primary dataframe
post_predictions = as.data.frame(t(post_summary)) %>% select(contains("y_pred"))
post_predictions = post_predictions["mean", ] %>% 
  pivot_longer(cols=contains("y_pred"), values_to="y_pred")
post_predictions$track_pop = data$track_pop

# Convert wide to long
post_predictions = post_predictions %>% select(track_pop, y_pred) %>% 
  mutate(index = row_number()) %>% 
  pivot_longer(cols=c("track_pop", "y_pred"), names_to="y") %>% 
  mutate(y = ifelse(y=="track_pop", "Observed", "Predicted"))

# Posterior predictive plot
ggplot(post_predictions, aes(linetype=y)) + 
  geom_density(aes(x=value), color="#c5050c", size=1.01, key_glyph=draw_key_path) + 
  theme_bw() +
  ggtitle("Posterior Predictions") +
  xlab("\nTrack Popularity")+
  ylab("Density\n") +
  labs(linetype="", caption="") +
  theme(plot.title=element_text(face="bold", size=20), 
        axis.title=element_text(size=12),
        plot.subtitle=element_text(size=8, face="plain", color="black"),
        legend.position="top", legend.justification='left', 
        legend.text=element_text(size=14),
        axis.text=element_text(color="black"))
ggsave("./plots/post_predictions.png", height=5, width=7)

# (RMSE = sqrt(1/n * sum(data_post$residual^2)))

#############
# Residuals #
#############

residuals = post_predictions %>% 
  pivot_wider(names_from="y", values_from="value") %>% 
  mutate(residuals=Observed-Predicted)

ggplot(residuals, aes(y=residuals, x=Predicted)) + 
  geom_point(size=0.95) +
  geom_smooth(method="loess", formula="y~x", se=FALSE, color="#c5050c") +
  theme_bw() +
  theme(plot.title=element_text(face="bold", size=20), 
        axis.title=element_text(size=12),
        plot.subtitle=element_text(size=8, face="plain", color="black"),
        axis.text=element_text(color="black")) +
  xlab("\nFitted") +
  ylab("Residual\n") +
  ggtitle("Residuals vs. Fitted")
ggsave("./plots/residuals.png", height=5, width=7)


#############################
# Standardized Coefficients #
############################ 
post_beta_means_stand = rownames_to_column(post_summary_stand, "param") %>% 
  filter(str_detect(param, "beta") & !str_detect(param, "tau|mu")) %>% 
  select(param, mean) %>% mutate(var_num=as.numeric(str_extract(param, "\\d+")),
                                 decade=as.numeric(str_extract(param, "\\d+(?=\\])"))) %>% 
  group_by(var_num) %>% summarize(beta_mean = mean(mean)) %>% arrange(desc(abs(beta_mean))) %>% 
  mutate(var = case_when(var_num == 1 ~ "Artist Popularity", 
                         var_num == 2 ~ "Loudness", 
                         var_num == 3 ~ "Danceability", 
                         var_num == 4 ~ "Speechiness", 
                         var_num == 5 ~ "Tempo", 
                         var_num == 6 ~ "Valence", 
                         var_num == 7 ~ "Instrumentalness", 
                         var_num == 8 ~ "Acousticness", 
                         var_num == 9 ~ "Liveness", 
                         var_num == 10 ~ "Duration", 
                         ))

ggplot(post_beta_means_stand, aes(x=var, y=beta_mean)) + 
  geom_col(fill="#c5050c", color="#282728") +
  geom_hline(yintercept=0, color="black") +
  scale_x_discrete(limits=post_beta_means_stand %>% pull(var)) +
  scale_y_continuous(limits=c(-1, 1), breaks=seq(-1, 1, 0.25)) +
  theme_bw() +
  theme(plot.title=element_text(face="bold", size=16), 
        axis.title=element_text(size=10),
        plot.subtitle=element_text(size=8, face="plain", color="black"),
        axis.text=element_text(color="black"),
        axis.text.x=element_text(angle=45, vjust=1, size=10, hjust=1, color="black")) +
  xlab("\nPredictor") +
  ylab("") +
  ggtitle("Posterior Coefficient Means\n(Standardized)")
ggsave("./plots/standardized_coeffs.png", height=5, width=7)


########################################
# Posterior Coefficient Distributions #
######################################

dance_beta_samples = rownames_to_column(as.data.frame(t(as.data.frame(post_model[3][[1]]))), 
                                        var="coef")
cols_to_pivot = colnames(dance_beta_samples %>% select(-coef))
dance_beta_samples = dance_beta_samples %>% 
  filter(substr(coef, 1, 1) == "3") %>%
  pivot_longer(cols=all_of(cols_to_pivot)) %>% 
  mutate(decade=str_sub(coef, start=-1))

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
ggplot(dance_beta_samples, aes(x=value, color=decade)) +
  geom_density(key_glyph=draw_key_path) +
  theme_bw() +
  theme(plot.title=element_text(face="bold", size=16), 
        axis.title=element_text(size=10),
        plot.subtitle=element_text(size=8, face="plain", color="black"),
        axis.text=element_text(color="black")) +
  ylab("Density") + 
  xlab("Danceability Coefficient") +
  ggtitle("Posterior Danceability\nCoefficient Distribution") +
  labs(color="Decade") +
  scale_color_manual(values=cbPalette)
ggsave("./plots/danceabiltiy_dist.png", height=5, width=7)


##################
# Scatter Plots #
################

modeling_data = data %>% select(track_pop, artist_pop, track_loudness, 
                       track_danceability, track_speechiness, 
                       track_tempo, track_valence,
                       track_instrumentalness, track_acousticness,
                       track_liveness, track_duration) %>% 
  
# modeling_data = modeling_data %>% rename("artiartist ")c
predictors = c("artist_pop", "track_loudness", "track_danceability", 
               "track_speechiness","track_tempo", "track_valence",
               "track_instrumentalness", "track_acousticness",
                "track_liveness", "track_duration")

for(predictor in predictors){
  predictor_formatted = str_to_title(str_split(predictor, "_")[[1]][2])
  if(predictor == "artist_pop"){
    predictor_formatted = "Artist Popularity"
  }
  print(ggplot(data, aes_string(y="track_pop", x=predictor)) + 
    geom_point(size=0.8, color="#c5050c") +
    theme_bw() + 
    theme(plot.title=element_text(face="bold", size=16), 
          axis.title=element_text(size=10),
          plot.subtitle=element_text(size=8, face="plain", color="black"),
          axis.text=element_text(color="black")) +
  xlab(predictor_formatted) + ylab("Popularity") + 
    ggtitle(paste("Popularity vs ", predictor_formatted, sep="")))
  ggsave(paste("./plots/pop_vs_", predictor, ".png", sep=""),height=5, width=7)
}
