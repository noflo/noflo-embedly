noflo = require 'noflo'
embedly = require 'embedly'

# @runtime noflo-nodejs

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
        if data.length is 1 and data[0].type is 'error'
          @outPorts.out.disconnect()
          return callback new Error data[0].error_message

        @outPorts.out.beginGroup url
        @outPorts.out.send data
        @outPorts.out.endGroup()
        callback()

exports.getComponent = -> new Extract
