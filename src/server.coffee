http      = require 'http'
path      = require 'path'
url       = require 'url'
routes    = require './routes'
{error}   = require './utils'

process.on 'uncaughtException', (err) ->
  error err

createServer = (opts) ->
  # Get full path to each test file
  root  = opts.testPath ? process.cwd()
  files = opts.files.slice()

  _cache   = {}
  bundles  = {}
  bundleRe = new RegExp files.join '|'

  http.createServer (req, res) ->
    # Only GET is supported.
    if req.method == 'HEAD'
      res.writeHead 200
      res.end()
      return

    if req.method != 'GET'
      res.writeHead 405
      res.end()
      return

    ctx =
      _cache:  _cache
      bundles: bundles
      files:   files
      opts:    opts
      req:     req
      res:     res
      root:    root

    {pathname} = url.parse req.url

    switch pathname
      when '/', '/index.html'
        routes.index.call ctx
      when '/mocha.css'
        routes.mocha.css.call ctx
      when '/mocha.js'
        routes.mocha.js.call ctx
      when '/prelude.js'
        routes.prelude.call ctx
      else
        if bundleRe.test req.url
          routes.bundle.call ctx
        else
          routes.static.call ctx

module.exports =
  createServer: createServer
