#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import time
import json
import spotipy
from datetime import date
import spotipy.util
from spotipy.oauth2 import SpotifyClientCredentials
import pandas as pd


# In[2]:


# List of playlists to request
playlist_links = ["https://open.spotify.com/playlist/37i9dQZF1DWXQyLTHGuTIz",
                  "https://open.spotify.com/playlist/37i9dQZF1DX43B4ApmA3Ee",
                  "https://open.spotify.com/playlist/37i9dQZF1DXaQBa5hAMckp",
                  "https://open.spotify.com/playlist/37i9dQZF1DX2ExTChOnD3g",
                  "https://open.spotify.com/playlist/37i9dQZF1DWVg6L7Yq13eC",
                  "https://open.spotify.com/playlist/37i9dQZF1DX3TYyWu8Zk7P",
                  "https://open.spotify.com/playlist/37i9dQZF1DX6rhG68uMHxl",
                  "https://open.spotify.com/playlist/37i9dQZF1DX26cozX10stk",
                  "https://open.spotify.com/playlist/37i9dQZF1DX0fr2A59qlzT",
                  "https://open.spotify.com/playlist/37i9dQZF1DWZLO9LcfSmxX",
                  "https://open.spotify.com/playlist/37i9dQZF1DWXbLOeOIhbc5",
                  "https://open.spotify.com/playlist/37i9dQZF1DX3MaR62kDrX7",
                  "https://open.spotify.com/playlist/37i9dQZF1DXas7qFgKz9OV",
                  "https://open.spotify.com/playlist/37i9dQZF1DXbE3rNuDfpVj",
                  "https://open.spotify.com/playlist/37i9dQZF1DX2O7iyPnNKby",
                  "https://open.spotify.com/playlist/37i9dQZF1DWXZ5eJ1sVtmf",
                  "https://open.spotify.com/playlist/37i9dQZF1DX7b12kdMQTpG",
                  "https://open.spotify.com/playlist/37i9dQZF1DX38yySwWsFRT",
                  "https://open.spotify.com/playlist/37i9dQZF1DX3MZ9dVGvZnZ",
                  "https://open.spotify.com/playlist/37i9dQZF1DX4qJrOCfJytN",
                  "https://open.spotify.com/playlist/37i9dQZF1DX4joPVMjBCAo",
                  "https://open.spotify.com/playlist/37i9dQZF1DX6TtJfRD994c",
                  "https://open.spotify.com/playlist/37i9dQZF1DX9ZZCtVNwklG",
                  "https://open.spotify.com/playlist/37i9dQZF1DXbUFx5bcjwWK",
                  "https://open.spotify.com/playlist/37i9dQZF1DXbKFudfYGcmj",
                  "https://open.spotify.com/playlist/37i9dQZF1DXayIOFUOVODK",
                  "https://open.spotify.com/playlist/37i9dQZF1DWZkDl55BkJmo",
                  "https://open.spotify.com/playlist/37i9dQZF1DWWKd15PHZNnl",
                  "https://open.spotify.com/playlist/37i9dQZF1DWWmGB2u14f8m",
                  "https://open.spotify.com/playlist/37i9dQZF1DX4PrR66miO50",
                  "https://open.spotify.com/playlist/37i9dQZF1DWUZv12GM5cFk", 
                 "https://open.spotify.com/playlist/37i9dQZF1DX9Ol4tZWPH6V",  
                 "https://open.spotify.com/playlist/37i9dQZF1DX0P7PzzKwEKl", 
                 "https://open.spotify.com/playlist/37i9dQZF1DXaW8fzPh9b08", 
                 "https://open.spotify.com/playlist/37i9dQZF1DWTWdbR13PQYH",  
                 "https://open.spotify.com/playlist/37i9dQZF1DWWzQTBs5BHX9",  
                 "https://open.spotify.com/playlist/37i9dQZF1DX1vSJnMeoy3V", 
                 "https://open.spotify.com/playlist/37i9dQZF1DX3j9EYdzv2N9",  
                 "https://open.spotify.com/playlist/37i9dQZF1DWYuGZUE4XQXm",  
                 "https://open.spotify.com/playlist/37i9dQZF1DX4UkKv8ED8jp",  
                 "https://open.spotify.com/playlist/37i9dQZF1DXc6IFF23C9jj",  
                 "https://open.spotify.com/playlist/37i9dQZF1DXcagnSNtrGuJ",  
                 "https://open.spotify.com/playlist/37i9dQZF1DX0yEZaMOXna3", 
                 "https://open.spotify.com/playlist/37i9dQZF1DX3Sp0P28SIer",  
                 "https://open.spotify.com/playlist/37i9dQZF1DX0h0QnLkMBl4",  
                 "https://open.spotify.com/playlist/37i9dQZF1DX9ukdrXQLJGZ",  
                 "https://open.spotify.com/playlist/37i9dQZF1DX8XZ6AUo9R4R",  
                 "https://open.spotify.com/playlist/37i9dQZF1DWTE7dVUebpUW",  
                 "https://open.spotify.com/playlist/37i9dQZF1DXe2bobNYDtW8",  
                 "https://open.spotify.com/playlist/37i9dQZF1DWVRSukIED0e9",  
                 "https://open.spotify.com/playlist/2fmTTbBkXi8pewbUvG3CeZ",
                 "https://open.spotify.com/playlist/5GhQiRkGuqzpWZSE7OU4Se"] 
playlist_URIs = [link.split("/")[-1].split("?")[0] for link in playlist_links]


# In[3]:


# Keys are saved as system environment variables
client_id = os.getenv("spotify_client_id")
client_secret = os.getenv("spotify_client_secret")

# Authenticate with Spotify API using id/secret keys
def authenticate(client_id, client_secret):
    client_credentials_manager = SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
    return spotipy.Spotify(client_credentials_manager = client_credentials_manager)
sp = authenticate(client_id, client_secret)


# In[4]:


# Override print for json/dict data
def prettyprint(x):
    if type(x) is dict:
        print(json.dumps(x, indent=4, sort_keys=True))
    else:
        print(x)
        
# Recursive function to scan through a dict and remove "key" at any level
def remove_key(container, key):
    if type(container) is dict:
        if key in container:
            del container[key]
        for v in container.values():
            remove_key(v, key)
    if type(container) is list:
        for v in container:
            remove_key(v, key)


# In[5]:


# Request track data for Spotify playlists
def get_playlist_data(playlist_URIs):
    
    if type(playlist_URIs) is str:
        playlist_URIs = [playlist_URIs]
        
    all_tracks_dict = dict()
    for playlist_URI in playlist_URIs:
        success = False
        while not success:
            try:
                print("Requesting playlist {} ".format(playlist_URI), end="")
                playlist_name = sp.user_playlist(user=None, playlist_id=playlist_URI, fields="name")["name"]
                print("('{}')".format(playlist_name), end="...")
                time.sleep(.1)
                all_tracks_dict[playlist_name] = sp.playlist_tracks(playlist_URI)["items"]
                print("Success!")
                time.sleep(.1)
                success = True
            except:
                print("\nERROR. Will try again in 30 seconds.")
                time.sleep(30)
    return all_tracks_dict
            
playlist_data = get_playlist_data(playlist_URIs)

# The "available_markets" key is gross and useless
remove_key(playlist_data, "available_markets")


# In[ ]:


def get_user_data(username, client_id, client_secret, redirect_uri="http://localhost:7777/callback",
                  song_limit=50, time_range="short_term", scope="user-top-read"):
    
    # Get user token -- Will request permission from user
    token = spotipy.util.prompt_for_user_token(username=username, 
                                           scope=scope, 
                                           client_id=client_id,   
                                           client_secret=client_secret,     
                                           redirect_uri=redirect_uri)
    
    # Request user's top tracks from Spotify
    user_data = "data/{}_data_{}.json".format(username, str(date.today()).replace("-", ""))
    if token:
        print("Requesting user data for r dist'{}'...".format(username), end="")
        sp = spotipy.Spotify(auth=token)
        results = sp.current_user_top_tracks(limit=song_limit, offset=0, time_range=time_range)
        for song in range(50):
            track_lust = []
            track_lust.append(results)
            with open(user_data, 'w', encoding='utf-8') as f:
                json.dump(track_lust, f, ensure_ascii=False, indent=4)
        print("Success!")
                
    else:
        print("No token provided!")
        return
    
    # Read/return the data
    with open(user_data) as f:
        data = json.load(f)
    return data[0]["items"]
    
user_data = get_user_data("james.m.hubbs@gmail.com", client_id, client_secret, song_limit=100)


# In[6]:


# Transform the Json response to a Pandas dataframe
# Playlist response seems to be formatted a little different than the user response, so we specify "source"
def transform_to_df(response_data, source, write_to_csv=False):
    
    if source == "playlist":
        file = "data/playlist_data_{}.csv".format(str(date.today()).replace("-", ""))
        data_list = []
        for playlist_name, track_list in response_data.items():
            for track in track_list:
                # Track info
                track_uri = track["track"]["uri"]
                track_name = track["track"]["name"]                      
                track_album = track["track"]["album"]["name"]
                track_album_release = track["track"]["album"]["release_date"]
                track_pop = track["track"]["popularity"]
                track_features = sp.audio_features(track_uri)[0]
                if track_features is None:
                    print("Track '{}' had no features! Skipping.".format(track_name))
                    continue
                track_danceability = track_features["danceability"]
                track_energy = track_features["energy"]
                track_key = track_features["key"]
                track_loudness = track_features["loudness"]
                track_mode = track_features["mode"]
                track_speechiness = track_features["speechiness"]
                track_acousticness = track_features["acousticness"]
                track_instrumentalness = track_features["instrumentalness"]
                track_liveness = track_features["liveness"]
                track_valence = track_features["valence"]
                track_tempo = track_features["tempo"]
                track_duration = track_features["duration_ms"]
                track_time_signature = track_features["time_signature"]

                # Artist info
                artist_uri = track["track"]["artists"][0]["uri"]
                artist_info = sp.artist(artist_uri)
                artist_name = track["track"]["artists"][0]["name"]
                artist_pop = artist_info["popularity"]
                artist_followers = artist_info["followers"]["total"]
                artist_genres_list = artist_info["genres"]
                artist_genres_string = ", ".join(artist_genres_list)

                data_list.append([playlist_name, track_uri, track_name, track_album, track_album_release, 
                             artist_uri, artist_name, artist_pop, artist_followers, artist_genres_string, 
                             track_pop, track_danceability, track_energy, track_key, track_loudness, 
                             track_mode, track_speechiness, track_acousticness, track_instrumentalness,
                             track_liveness, track_valence, track_tempo, track_duration, track_time_signature])
        df = pd.DataFrame(data_list, 
                          columns=["playlist_name", "track_uri", "track_name", "track_album", "track_album_release", 
                                   "artist_uri", "artist_name", "artist_pop", "artist_followers", "artist_genres_string", 
                                   "track_pop", "track_danceability", "track_energy", "track_key", "track_loudness", 
                                   "track_mode", "track_speechiness", "track_acousticness", "track_instrumentalness",
                                   "track_liveness", "track_valence", "track_tempo", "track_duration", "track_time_signature"])
        if write_to_csv:
            df.to_csv(file)
        return df
    
    elif source == "user":
        file = "data/user_data_{}.csv".format(str(date.today()).replace("-", ""))
        data_list = []
        for track in response_data:
            # Track info
            track_uri = track["uri"]
            track_name = track["name"] 
            track_album = track["album"]["name"]
            track_album_release = track["album"]["release_date"]
            track_pop = track["popularity"]
            track_features = sp.audio_features(track_uri)[0]
            if track_features is None: 
                print("Track '{}' had no features! Skipping.".format(track_name))
                continue
            track_danceability = track_features["danceability"]
            track_energy = track_features["energy"]
            track_key = track_features["key"]
            track_loudness = track_features["loudness"]
            track_mode = track_features["mode"]
            track_speechiness = track_features["speechiness"]
            track_acousticness = track_features["acousticness"]
            track_instrumentalness = track_features["instrumentalness"]
            track_liveness = track_features["liveness"]
            track_valence = track_features["valence"]
            track_tempo = track_features["tempo"]
            track_duration = track_features["duration_ms"]
            track_time_signature = track_features["time_signature"]

            # Artist info
            artist_uri = track["artists"][0]["uri"]
            artist_info = sp.artist(artist_uri)
            artist_name = track["artists"][0]["name"]
            artist_pop = artist_info["popularity"]
            artist_followers = artist_info["followers"]["total"]
            artist_genres_list = artist_info["genres"]
            artist_genres_string = ", ".join(artist_genres_list)

            data_list.append([track_uri, track_name, track_album, track_album_release, 
                             artist_uri, artist_name, artist_pop, artist_followers, artist_genres_string, 
                             track_pop, track_danceability, track_energy, track_key, track_loudness, 
                             track_mode, track_speechiness, track_acousticness, track_instrumentalness,
                             track_liveness, track_valence, track_tempo, track_duration, track_time_signature])

        df = pd.DataFrame(data_list, 
                          columns=["track_uri", "track_name", "track_album", "track_album_release", 
                                   "artist_uri", "artist_name", "artist_pop", "artist_followers", "artist_genres_string", 
                                   "track_pop", "track_danceability", "track_energy", "track_key", "track_loudness", 
                                   "track_mode", "track_speechiness", "track_acousticness", "track_instrumentalness",
                                   "track_liveness", "track_valence", "track_tempo", "track_duration", "track_time_signature"])
        if write_to_csv:
            df.to_csv(file)
        return df
    else:
        return

user_df = transform_to_df(user_data, source="user", write_to_csv=True)
playlist_df = transform_to_df(playlist_data, source="playlist", write_to_csv=True)

