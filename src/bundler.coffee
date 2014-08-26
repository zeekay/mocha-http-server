postmortem = require 'postmortem'
requisite  = require 'requisite'

exports.prelude = (cb) ->
  requisite.bundle {preludeOnly: true}, (err, bundle) ->
    cb null, bundle.toString()

exports.bundle = (cb) ->
  opts =
    prelude:     false
    base:        @root
    entry:       @file
    moduleCache: @_cache

  done = (err, bundle) ->
    if err?
      postmortem.prettyPrint err
      cb err
    else
      cb null, bundle.toString()

  if (bundle = @bundles[@file])?
    return bundle.parse done

  requisite.bundle opts, (err, bundle) =>
    @bundles[@file] = bundle

    for k,v of bundle.moduleCache
      @_cache[k] = v

    done err, bundle
