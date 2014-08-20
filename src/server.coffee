module.exports = (options) ->
  http.createServer (req, res) ->
    switch req.url
      when '/', '/index.html'
        res.writeHead 200, 'Content-Type': 'text/html'
        res.write '''
          <html>
          <head>
            <meta charset="utf-8">
            <title>Mocha Tests</title>
            <link rel="stylesheet" href="/mocha.css" />
          </head>
          <body>
            <div id="mocha"></div>
            <script src="http://code.jquery.com/jquery-2.1.1.min.js"></script>
            <script src="/mocha.js"></script>
            <script src="/.test/mvstar.js"></script>
            <script>
              mocha.checkLeaks();
              mocha.globals(['jQuery']);
              mocha.run();
            </script>
          </body>
          </html>
        '''
        res.end()
      when '/mocha.css'
        res.writeHead 200, 'Content-Type': 'text/css'
        fs.createReadStream(__dirname + '/node_modules/mocha/mocha.css').pipe(res)
      when '/mocha.js'
        res.writeHead 200, 'Content-Type': 'application/javascript'
        fs.createReadStream(__dirname + '/node_modules/mocha/mocha.js').pipe(res)
      else
        unless /coffee|js|map/.test req.url.split('.').pop()
          res.writeHead 404
          res.end()
          return

        path = __dirname + req.url
        fs.exists path, (exists) ->
          if exists
            res.writeHead 200, 'Content-Type': 'application/javascript'
            fs.createReadStream(path).pipe(res)
          else
            res.writeHead 404
            res.end()
