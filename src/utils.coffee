fs   = require 'fs'
path = require 'path'

error = (message) ->
  console.error message
  process.exit 1

# walks all file/dirs and returns complete list of files.
getFiles = (opts, cb) ->
  results = []
  seen    = {}

  pending = opts.files.length
  fileRe = /\.coffee$|\.js$/

  for file in opts.files
    walk file, opts, (err, files) ->
      for file in files
        results.push file if fileRe.test file
      cb null, results unless --pending

# walks dir, returns list of files, or just dir (if it's a file).
walk = (dir, opts, cb) ->
  unless cb?
    [cb, opts] = [opts, {}]

  opts.recurse ?= true

  fs.stat dir, (err, stats) ->
    unless stats?
      return cb null, []

    unless stats.isDirectory()
      return cb null, [dir]

    fs.readdir dir, (err, files) ->
      results = []

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
  error:    error
  getFiles: getFiles
  walk:     walk
