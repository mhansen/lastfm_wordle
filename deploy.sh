#!/bin/sh
coffee -c -o public thempipes.coffee
haml --format html5 index.haml public/index.html
rsync -r --delete public/ vps:www/lastfmwordle.com
