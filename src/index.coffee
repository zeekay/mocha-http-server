module.exports =
  createServer: (opts = {}) ->
    (require './server') opts

  run: (port = 8080, opts = {}) ->
    server = @createServer opts
    server.listen port, ->
      console.log 'listening on :8080'
      exec 'open http://localhost:8080'
