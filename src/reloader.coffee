do ->
  request = (method, url, cb) ->
    req = new XMLHttpRequest()

    req.addEventListener 'load', ->
      cb null, req.resText
    req.addEventListener 'timeout', ->
      cb null
    req.addEventListener 'abort', ->
      cb new Error 'Request aborted!'
    req.addEventListener 'error', ->
      cb new Error 'Request had an error!'

    req.open method, url, true
    req.send()
    req
  request.get = (url, cb) -> request 'GET', url, cb

  reload = ->
    setInterval ->
      request.get '/', (err) ->
        unless err?
          location.reload()
    , 100

  do poll = ->
    request.get '/poll', (err) ->
      if err?
        reload()
      else
        poll()
