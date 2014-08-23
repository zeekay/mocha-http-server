http      = require 'http'
path      = require 'path'
routes    = require './routes'
{error}   = require './utils'

process.on 'uncaughtException', (err) ->
  error err

createServer = (opts) ->
  # Get full path to each test file
  root = opts.testPath ? process.cwd()

  files = []
  for file in opts.files
    files.push path.join root, file

  http.createServer (req, res) ->
    ctx =
      files: files
      opts:  opts
      req:   req
      res:   res
      root:  root

    switch req.url
      when '/', '/index.html'
        routes.index.call ctx
      when '/mocha.css'
        routes.mocha.css.call ctx
      when '/mocha.js'
        routes.mocha.js.call ctx
      when '/bundle.js'
        routes.bundle.call ctx
      else
        routes.static.call ctx

module.exports =
  createServer: createServer
