bundle     = require './bundle'
fs         = require 'fs'
path       = require 'path'
{error}    = require './utils'

try
  mochaPath = path.dirname require.resolve 'mocha'
catch err
  error 'Unable to find mocha! `npm install -g mocha`'

module.exports =
  index: ->
    @res.writeHead 200, 'Content-Type': 'text/html'

    checkLeaks = if @opts.checkLeaks then 'mocha.checkLeaks();' else ''
    globals    = "mocha.globals(#{JSON.stringify @opts.globals});"

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
        <script src="/bundle.js"></script>
        <script>
          #{checkLeaks}
          #{globals}
          mocha.run();
        </script>
      </body>
      </html>
    """
    @res.end()

  mocha:
    css: ->
      @res.writeHead 200, 'Content-Type': 'text/css'
      fs.createReadStream(mochaPath + '/mocha.css').pipe(@res)

    js: ->
      @res.writeHead 200, 'Content-Type': 'application/javascript; charset=UTF-8'
      fs.createReadStream(mochaPath + '/mocha.js').pipe(@res)

  bundle: ->
    if @req.method == 'HEAD'
      @res.writeHead 200
      return @res.end()

    if @req.method != 'GET'
      @res.writeHead 405
      return @res.end()

    now = new Date().toUTCString()
    headers = 'Content-Type': 'application/javascript; charset=UTF-8'
    unless @res.getHeader 'Cache-Control'
      headers['Cache-Control'] = 'public, max-age=0'
    unless @res.getHeader 'Date'
      headers['Date'] = now
    unless @res.getHeader 'Last-Modified'
      headers['Last-Modified'] = now

    bundle @files, (err, src) =>
      if err?
        @res.writeHead 500
        @res.end()
      else
        @res.writeHead 200, headers
        @res.end src

  static: ->
    file = path.join @root, @req.url

    fs.exists file, (exists) =>
      unless exists
        @res.writeHead 404
        return @res.end()

      if @req.method == 'HEAD'
        @res.writeHead 200
        return @res.end()

      if @req.method != 'GET'
        @res.writeHead 405
        return @res.end()

      return fs.createReadStream(file).pipe(@res)
