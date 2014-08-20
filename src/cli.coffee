error = (message) ->
  console.error message
  process.exit 1

usage = ->
  console.log """
  mocha-http [options]

  Options:
    --browser, -b   Open browser automatically
    --compilers, -c Specify compiler to use for a given extension
    --host, -h      Hostname to bind to
    --port, -p      Port to listen on
  """
  process.exit 0

opts =
  host:      'localhost'
  port:      8080
  compilers: ''
  browser:   false

args = process.argv.slice 2

while opt = args.shift()
  switch opt
    when '--help', '-v'
      usage()
    when '--open', '-o'
      opts.open = true
    when '--host', '-h'
      opts.host = args.shift()
    when '--port', '-p'
      opts.port = parseInt args.shift(), 10
    when '--compilers', '-c'
      opts.compilers = args.shift()
    else
      error 'Unrecognized option' if opt.charAt(0) is '-'

server = (require './server') opts
server.listen opts.port, ->
  console.log "mocha-http running on port :#{opts.port}"

if opts.browser
  exec = require 'executive'
  switch os.platform()
    when 'darwin'
      exec "open http://#{opts.host}:#{opts.port}"
    when 'linux'
      exec "xdg-open http://#{opts.host}:#{opts.port}"
