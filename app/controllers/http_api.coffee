
module.exports = (app) ->
  io = app.io
  Data = app.models.Data

  app.get (/^\/topics\/(.+)$/), (req, res) ->
    topic = req.params[0]

    topics = req.session.topics || []
    index = topics.indexOf(topic)
    if index >= 0
      topics = [].concat(topics.splice(0, index), topics.splice(index + 1, req.session.topics.length))
    topics.push(topic)
    topics.pull() if topics.length > 5
    req.session.topics = topics

    Data.find topic, (data, err) ->
      type = req.accepts(['txt', 'json', 'html'])

      if type == "html"
        res.render 'topic.hbs', topic: topic
      else if type == 'json'
        res.contentType('json')
        try
          # if it's a json, we parse it and render
          value = JSON.parse(data.getValue())
        catch e
          # else we transform it in string
          value = "" + data.getValue()
        if err?
          res.send 404
        else
          res.json value
      else if type == 'txt'
        if err?
          res.send "", 404
        else
          res.send "" + data.getValue()
      else
        res.send "", 406

  app.put /^\/topics\/(.+)$/, (req, res) ->
    topic = req.params[0]
    Data.findOrCreate(topic, req.body.payload)
    res.send 204