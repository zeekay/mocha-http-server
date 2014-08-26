do ->
  reload = ->
    setInterval ->
      request '/', (err) ->
        unless err?
          location.reload()
    , 100

  request = (url, cb) ->
    req = new XMLHttpRequest()

    req.addEventListener 'load', ->
      cb null
    req.addEventListener 'error', ->
      cb new Error 'Request had an error!'
    req.addEventListener 'abort', ->
      cb new Error 'Request aborted!'

    handler = ->
      return if req.readyState != 4 and req.readyState != 3
      return if req.readyState == 3 and req.status != 200
      return if req.readyState == 4 and req.status != 200

      return unless req.resText?

      until prev == req.resText.length
        if req.readyState == 4 and prev == req.resText.length
          break

        prev = req.resText.length
        res   = req.resText.substring next
        lines = res.split '\n'
        next  = next + (res.lastIndexOf '\n')  + 1
        unless res[res.length - 1] is '\n'
          lines.pop()

        for line in lines
          console.log line

    req.open 'GET', url, true
    req.onreadystatechange = handler
    req.send()
    req

  request '/poll', (err) ->
    reload() if err?
