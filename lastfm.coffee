#!/usr/bin/env coffee
express = require 'express'
app = express.createServer(express.logger())
app.use(express.staticProvider(__dirname + '/public'))
app.get '/', (req, res) => res.render 'index.haml', { layout: false, format: "html5" }
app.listen 2999
