fs   = require 'fs'
path = require 'path'

getFiles = (opts, cb) ->
  results = []
  pending = opts.files.length

  for file in opts.files
    do (file) ->
      fs.stat file, (err, stats) ->
        unless stats?
          return cb null, results unless --pending

        unless stats.isDirectory()
          results.push file
          return cb null, results unless --pending

        walk file, opts, (err, files) ->
          results = results.concat files
          cb null, results unless --pending

walk = (dir, opts, cb) ->
  results = []

  fs.readdir dir, (err, files) ->
    return cb err if err?

    pending = files.length
    return cb null, results unless pending

    for file in files
      do (file) ->
        file = path.join dir, file

        fs.stat file, (err, stats) ->
          return cb err if err?

          unless stats.isDirectory()
            results.push file
            return cb null, results unless --pending

          if opts.recurse
            walk file, (err, files) ->
              results = results.concat files
              cb null, results unless --pending
          else
            cb null, results unless --pending

module.exports =
  getFiles: getFiles
  walk:     walk
