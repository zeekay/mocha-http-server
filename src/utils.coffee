fs   = require 'fs'
path = require 'path'

walk = (dir, cb) ->
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

          if stats.isDirectory()
            walk file, (err, files) ->
              results = results.concat files
              cb null, results unless --pending
          else
            results.push file
            cb null, results unless --pending

module.exports =
  walk: walk
