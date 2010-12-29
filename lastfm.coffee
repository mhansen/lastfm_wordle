#!/usr/bin/env coffee

express = require 'express'
http = require 'http'
restclient = require 'node-restclient'
util = require 'util'

app = express.createServer()
lastfm_api_key = "b5f4ec6308ea9378b9e82fbf7f3edf65"

app.get '/', (req, res) =>
    res.render 'index.html'
    res.send('hello world')

app.get '/hello/:user', (req, res) =>
    fetch_fave_artists req.params.user, (fave_artists) =>
        res.send(fave_artists)
    
dummy_fetch_fave_artists = (username, callback) =>
    callback {
        "Miike Snow" : 250
        "Pearl Jam" : 100
        "Rolling Stones" : 50
    }

api_fetch_fave_artists = (username, callback) =>
    data = {
        api_key : lastfm_api_key
        format: "json"
        method : "user.gettopartists"
        user: username
    }
    transform = (response) =>
        text_artists = for artist in response.topartists.artist
            # whitespace and colons are delimiters in wordle's input.
            # replace them with harmless (to wordle) tildes
            clean_name = artist.name.replace(/(\s|:)/g, "~")
            clean_name + ":" + artist.playcount

        callback text_artists.join "\n"

    restclient.get "http://ws.audioscrobbler.com/2.0/", data, transform, "json"

fetch_fave_artists = api_fetch_fave_artists

app.listen 3000
