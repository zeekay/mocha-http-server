error = (message) ->
  console.error message
  process.exit 1

usage = ->
  console.log """
  mocha-http [options] [files]

  Options:
    -?, --help                      output usage information
    -v, --version                   output the version number
    -b, --browser                   open browser automatically
    -h, --host                      hostname to bind to
    -p, --port                      port to listen on
    -r, --require <name>            require the given module
    -t, --timeout <ms>              set test-case timeout in milliseconds [2000]
    --check-leaks                   check for global variable leaks
    --compilers <ext>:<module>,...  specify compiler to use for a given extension
    --globals <names>               allow the given comma-delimited global [names]
    --recursive                     include sub directories
  """
  process.exit 0

version = ->
  console.log (require '../package').version
  process.exit 0

opts =
  browser:   false
  checkLeaks: false
  compilers: []
  globals:   []
  host:      'localhost'
  port:      8080
  recursive: false
  timeout:   2000

args = process.argv.slice 2

while opt = args.shift()
  switch opt
    when '-?', '--help'
      usage()
    when '-v', '--version'
      version()
    when '-b', '--browser'
      opts.browser = true
    when '-h', '--host'
      opts.host = args.shift()
    when '-p', '--port'
      opts.port = parseInt args.shift(), 10
    when '--compilers'
      opts.compilers = args.shift().split ','
    else
      opts.files.push opt

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
