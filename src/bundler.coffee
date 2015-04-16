fs         = require 'fs'

convert    = require 'convert-source-map'
postmortem = require 'postmortem'
requisite  = require 'requisite'


exports.prelude = (cb) ->
  requisite.bundle {preludeOnly: true}, (err, bundle) ->
    cb null, bundle.toString()

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
      cb null, (bundle.toString sourceMap: true)

  if (bundle = @bundles[@file])?
    return bundle.parse done

  requisite.bundle opts, (err, bundle) =>
    @bundles[@file] = bundle
    done err, bundle
