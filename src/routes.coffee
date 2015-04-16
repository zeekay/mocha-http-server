fs         = require 'fs'
path       = require 'path'
bundler    = require './bundler'
{error}    = require './utils'

try
  mochaPath = path.dirname require.resolve 'mocha'
catch err
  error 'Unable to find mocha! `npm install -g mocha`'

reloaderPath = path.join __dirname, '..', 'lib', 'reloader.js'

# Write headers for normal 200 request
writeHead = (contentType, cache = false) ->
  headers = {}

  if contentType?
    headers['Content-Type'] = "#{contentType}; charset=UTF-8"

  # Prevent caching
  unless cache
    now = new Date().toUTCString()
    unless @res.getHeader 'Cache-Control'
      headers['Cache-Control'] = 'public, max-age=0'
    unless @res.getHeader 'Date'
      headers['Date'] = now
    unless @res.getHeader 'Last-Modified'
      headers['Last-Modified'] = now

  # Add source map header to js/coffee files
  if /\.js$|\.coffee$/.test @req.url
    headers['SourceMap'] = @req.url + '.map'

  @res.writeHead 200, headers

module.exports =
  # Serve index content
  index: ->
    writeHead.call @, 'text/html'

    checkLeaks = if @opts.checkLeaks then 'mocha.checkLeaks();' else ''
    globals    = "mocha.globals(#{JSON.stringify @opts.globals});"
    files      =  ("<script src='/#{f}'></script>" for f in @files).join '\n  '

    @res.write """
      <html>
      <head>
        <meta charset="utf-8">
        <title>Mocha Tests</title>
        <link rel="stylesheet" href="/mocha.css" />
      </head>
      <body>
        <div id="mocha"></div>
        <script src="/mocha.js"></script>
        <script>mocha.setup('bdd')</script>
        <script src="/mocha-reloader.js"></script>
        <script src="/requisite-prelude.js"></script>
        <script src="/source-map-support.js"></script>
        <script>
          (function() {
            var sms = require('./source-map-support');
            var ignoreJs = /mocha.js|mocha-reloader.js|requisite-prelude.js|source-map-support.js|native /
            sms.install({
              retrieveSourceMap: function(source) {
                if (ignoreJs.test(source)) {
                  return null;
                }
                return sms.retrieveSourceMap(source)
              }
            })
          }())
        </script>
        #{files}
        <script>
          #{checkLeaks}
          #{globals}
          mocha.run();
        </script>
      </body>
      </html>
    """
    @res.end()

  # Serve mocha assets
  mocha:
    css: ->
      writeHead.call @, 'text/css', true
      fs.createReadStream(mochaPath + '/mocha.css').pipe(@res)

    js: ->
      writeHead.call @, 'application/javascript', true
      fs.createReadStream(mochaPath + '/mocha.js').pipe(@res)

  # Serve source map support for proper stack traces
  sourceMapSupport: ->
    bundler.sourceMapSupport (err, src) =>
      writeHead.call @, 'application/javascript', true
      @res.end src

  # Serve prelude which defines require, require.define, etc.
  prelude: ->
    bundler.prelude (err, src) =>
      writeHead.call @, 'application/javascript', true
      @res.end src

  # Server js bundles
  bundle: ->
    @file = path.join @root, @req.url

    bundler.bundle.call @, (err, src) =>
      if err?
        @res.writeHead 500
        @res.end()
      else
        writeHead.call @, 'application/javascript'
        @res.end src

  # Serve static files
  static: ->
    file = path.join @root, @req.url

    fs.exists file, (exists) =>
      unless exists
        @res.writeHead 404
        return @res.end()

      writeHead.call @, null, true
      return fs.createReadStream(file).pipe(@res)

  # Serve client-side script to automate reloading.
  reloader: ->
    writeHead.call @, 'application/javascript'
    fs.createReadStream(reloaderPath).pipe(@res)

  # Leave connection open for up to 60 seconds.
  poll: ->
    writeHead.call @, 'text/plain'
    start = +new Date
    id = setInterval =>
      now = +new Date
      if now > start+60*1000
        clearInterval id
        @res.end()
      else
        @res.write "#{now}\n"
    , 2000
