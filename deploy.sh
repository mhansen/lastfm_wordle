#!/bin/sh
coffee -c public/thempipes.coffee
haml index.haml public/index.html
rsync -r --delete public/ vps:www/lastfmwordle.com
