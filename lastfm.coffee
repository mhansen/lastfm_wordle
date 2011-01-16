#!/usr/bin/env coffee
express = require 'express'
app = express.createServer(express.logger())
app.use(express.staticProvider(__dirname + '/public'))
app.get '/', (req, res) => res.render 'index.haml', { layout: false }
app.listen 2999
