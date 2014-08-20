exec              = require 'executive'
os                = require 'os'
server            = require './server'
{getFiles, error} = require './utils'

usage = ->
  console.log """
  mocha-http [options] [files]

  Options:
    -?, --help                      output usage information
    -v, --version                   output the version number
    -b, --browser                   open browser automatically
    -h, --host                      hostname to bind to
    -p, --port                      port to listen on
    -t, --timeout <ms>              set test-case timeout in milliseconds [2000]
    --check-leaks                   check for global variable leaks
    --compilers <ext>:<module>,...  specify compiler to use for a given extension
    --globals <names>,...           allow the given global [names]
    --recursive                     include sub directories
    --require <module>,...          require the given modules
  """
  process.exit 0

version = ->
  console.log (require '../package').version
  process.exit 0

opts =
  browser:    false
  checkLeaks: false
  compilers:  []
  files:      []
  globals:    []
  host:       'localhost'
  port:       8080
  recursive:  false
  timeout:    2000

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
    when '-t', '--timeout'
      opts.timeout = parseInt args.shift(), 10
    when '--check-leaks'
      opts.checkLeaks = true
    when '--compilers'
      opts.compilers = args.shift().split ','
    when '--globals'
      opts.globals = args.shift().split ','
    when '--require'
      opts.globals = args.shift().split ','
    when '--recursive'
      opts.recursive = true
    else
      error 'Unrecognized option' if opt.charAt(0) is '-'
      opts.files.push opt

error 'No test files specified' unless opts.files.length

getFiles opts, (err, files) ->
  error err if err?
  error 'No test files found' unless files.length

  opts.files = files

  (server.createServer opts).listen opts.port, ->
    console.log "mocha-http running on port :#{opts.port}"

  if opts.browser
    switch os.platform()
      when 'darwin'
        exec "open http://#{opts.host}:#{opts.port}"
      when 'linux'
        exec "xdg-open http://#{opts.host}:#{opts.port}"
