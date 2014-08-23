postmortem = require 'postmortem'
browserify = require 'browserify'
coffeeify  = require 'coffeeify'

module.exports = (files, cb) ->
  b = browserify()
  for file in files
    b.add file
  b.transform coffeeify
  b.bundle (err, src) ->
    if err?
      postmortem.prettyPrint err
      return cb err

    cb null, src
