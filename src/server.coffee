http       = require 'http'
path       = require 'path'
url        = require 'url'
postmortem = require 'postmortem'

bundler   = require './bundler'
routes    = require './routes'

shallowClone = (o) ->
  o2 = {}
  for own k,v of o
    o2[k] = v
  o2

process.on 'uncaughtException', (err) ->
  postmortem.prettyPrint err
  process.exit 1

createServer = (opts) ->
  # Get full path to each test file
  root  = opts.testPath ? process.cwd()
  files = opts.files.slice()

  _cache   = {}
  bundles  = {}
  bundleRe = new RegExp files.join '|'

  # Create http server
  server = http.createServer (req, res) ->
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

  # Pre-bundle all modules so we can dedupe dependencies.
  server.prepareBundles = (cb) ->
    pending = (path.resolve f for f in files)

    prepareBundle = (file) ->
      console.log 'bundling', file
      opts =
        _cache: _cache
        bundles: bundles
        file:    file
        prepare: true
        root:    root

      bundler.bundle.call opts, (err, bundle) ->
        if pending.length
          # Get next module to bundle
          next = pending.shift()

          # Create module cache for next bundle
          _cache[next] = {}

          for k,v of bundle.moduleCache
            mod = shallowClone v
            mod.external = true  # indicate it's external to other bundles
            _cache[next][k] = mod

          # Bundle next module
          prepareBundle next
        else
          cb()
    prepareBundle pending.shift()

  server

module.exports =
  createServer: createServer
