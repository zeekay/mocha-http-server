fs   = require 'fs'
http = require 'http'
path = require 'path'

try
  mochaPath = path.dirname(require.resolve('mocha'))
catch err
  console.error 'Unable to find mocha! `npm install -g mocha`'
  process.exit 1

createServer = (options) ->
  process.on 'uncaughtException', (err) ->
    console.error err
    process.exit 1

  http.createServer (req, res) ->
    writeHead = (code, type) ->
      res.writeHead code, 'Content-Type': type

    routes =
      index: ->
        writeHead 200, 'text/html'

        checkLeaks = if options.checkLeaks then 'mocha.checkLeaks();' else ''
        files      = ("<script src='#{f}'></script>" for f in options.files).join '\n'
        globals    = "mocha.globals(#{JSON.stringify options.globals});"

        res.write """
          <html>
          <head>
            <meta charset="utf-8">
            <title>Mocha Tests</title>

            <!-- Mocha assets -->
            <link rel="stylesheet" href="/mocha.css" />
            <script src="/mocha.js"></script>
          </head>
          <body>
            <div id="mocha"></div>

            <!-- Test files -->
            #{files}

            <!-- Test Setup -->
            <script>
              #{checkLeaks}
              #{globals}
              mocha.run();
            </script>
          </body>
          </html>
        """
        res.end()

      mocha:
        css: ->
          writeHead 200, 'text/css'
          fs.createReadStream(mochaPath + '/mocha.css').pipe(res)

        js: ->
          writeHead 200, 'application/javascript'
          fs.createReadStream(mochaPath + '/mocha.js').pipe(res)

      static: ->
        unless /coffee|js|map/.test req.url.split('.').pop()
          writeHead 404
          res.end()
          return

        path = __dirname + req.url

        fs.exists path, (exists) ->
          if exists
            writeHead 200, 'application/javascript'
            fs.createReadStream(path).pipe(res)
          else
            writeHead 404
            res.end()

    switch req.url
      when '/', '/index.html'
        routes.index()
      when '/mocha.css'
        routes.mocha.css()
      when '/mocha.js'
        routes.mocha.js()
      else
        routes.static()

module.exports =
  createServer: createServer
