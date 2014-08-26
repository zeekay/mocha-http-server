postmortem = require 'postmortem'
requisite  = require 'requisite'

exports.prelude = (cb) ->
  requisite.bundle {preludeOnly: true}, (err, bundle) ->
    cb null, bundle.toString()

exports.bundle = (cb) ->
  opts =
    base:        @root
    entry:       @file
    moduleCache: @_cache[@file]
    prelude:     false

  done = (err, bundle) =>
    if err?
      postmortem.prettyPrint err
      return cb err

    if @prepare
      cb null, bundle
    else
      cb null, bundle.toString()

  if (bundle = @bundles[@file])?
    return bundle.parse done

  requisite.bundle opts, (err, bundle) =>
    @bundles[@file] = bundle
    done err, bundle
