fs         = require 'fs'
path       = require 'path'
bundler    = require './bundler'
{error}    = require './utils'

try
  mochaPath = path.dirname require.resolve 'mocha'
catch err
  error 'Unable to find mocha! `npm install -g mocha`'

writeHead = (contentType) ->
  now = new Date().toUTCString()
  headers =
    'Content-Type': "#{contentType}; charset=UTF-8"
  unless @res.getHeader 'Cache-Control'
    headers['Cache-Control'] = 'public, max-age=0'
  unless @res.getHeader 'Date'
    headers['Date'] = now
  unless @res.getHeader 'Last-Modified'
    headers['Last-Modified'] = now
  @res.writeHead 200, headers

module.exports =
  index: ->
    writeHead.call @, 'text/html'

    checkLeaks = if @opts.checkLeaks then 'mocha.checkLeaks();' else ''
    globals    = "mocha.globals(#{JSON.stringify @opts.globals});"
    files      =  ("<script src='#{f}'></script>" for f in @files).join '\n  '

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
        <script src="/prelude.js"></script>
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

  mocha:
    css: ->
      writeHead.call @, 'text/css'
      fs.createReadStream(mochaPath + '/mocha.css').pipe(@res)

    js: ->
      writeHead.call @, 'application/javascript'
      fs.createReadStream(mochaPath + '/mocha.js').pipe(@res)

  prelude: ->
    bundler.prelude (err, src) =>
      writeHead.call @, 'application/javascript'
      @res.end src

  bundle: ->
    @file = path.join @root, @req.url

    bundler.bundle.call @, (err, src) =>
      if err?
        @res.writeHead 500
        @res.end()
      else
        writeHead.call @, 'application/javascript'
        @res.end src

  static: ->
    file = path.join @root, @req.url

    fs.exists file, (exists) =>
      unless exists
        @res.writeHead 404
        return @res.end()

      return fs.createReadStream(file).pipe(@res)
