noflo = require 'noflo'
embedly = require 'embedly'

class Extract extends noflo.AsyncComponent
  constructor: ->
    @token = ''
    @inPorts =
      url: new noflo.Port 'string'
      token: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.token.on 'data', (@token) =>

    super 'url'

  doAsync: (url, callback) ->
    unless @token
      return callback new Error 'Embed.ly API token required'

    embed = new embedly
      key: @token
    , (err, api) =>
      return callback err if err

      @outPorts.out.connect()
      api.extract
        url: url
        format: 'json'
      , (err, data) =>
        if err
          @outPorts.out.disconnect()
          return callback err

        @outPorts.out.beginGroup url
        @outPorts.out.send data
        @outPorts.out.endGroup()
        @outPorts.out.disconnect()
        callback()

exports.getComponent = -> new Extract
