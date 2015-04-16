fs         = require 'fs'

convert    = require 'convert-source-map'
postmortem = require 'postmortem'
requisite  = require 'requisite'

cached =
  prelude:          null
  sourceMapSupport: null

exports.prelude = (cb) ->
  if cached.prelude?
    return cb null, cached.prelude

  opts =
    globalRequire: true
    preludeOnly:   true
    sourceMap:     false

  requisite.bundle opts, (err, bundle) ->
    throw err if err?
    cached.prelude = bundle.toString()
    cb null, cached.prelude

exports.sourceMapSupport = (cb) ->
  if cached.sourceMapSupport?
    return cb null, cached.sourceMapSupport

  opts =
    base:      __dirname + '/../node_modules/postmortem/node_modules/source-map-support'
    prelude:   false
    sourceMap: false

  opts.entry = opts.base + '/source-map-support.js'

  requisite.bundle opts, (err, bundle) ->
    throw err if err?
    cached.sourceMapSupport = bundle.toString()
    cb null, cached.sourceMapSupport

exports.bundle = (cb) ->
  # Just return map files
  isMap = /\.map$/.test @file

  opts =
    base:        @root
    entry:       @file.replace /\.map$/, ''
    moduleCache: @_cache[@file]
    prelude:     false

  # Just return map files
  isMap = /\.map$/.test @file

  done = (err, bundle) =>
    if err?
      postmortem.prettyPrint err
      return cb err

    if @prepare
      cb null, bundle
      return

    if isMap
      cb null, (bundle.toString onlySourceMap: true)
    else
      @res.setHeader 'SourceMap', @req.url + '.map'
      cb null, (bundle.toString sourceMap: false)

  if (bundle = @bundles[@file])?
    return bundle.parse done

  requisite.bundle opts, (err, bundle) =>
    @bundles[@file] = bundle
    done err, bundle
