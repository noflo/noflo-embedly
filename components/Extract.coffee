noflo = require 'noflo'
embedly = require 'embedly'

# @runtime noflo-nodejs

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'cloud-download'
  c.description = 'Extract contents from URL using Embed.ly'
  c.token = null
  c.inPorts.add 'token',
    description: 'Embed.ly API token'
    datatype: 'string'
    process: (event, payload) ->
      c.token = payload if event is 'data'
  c.inPorts.add 'url',
    description: 'URL to extract'
    datatype: 'string'
  c.outPorts.add 'out',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['url']
    out: 'out'
    async: true
    forwardGroups: true
  , (url, groups, out, callback) ->
    unless c.token
      return callback new Error 'Embed.ly API token required'
    embed = new embedly
      key: c.token
    , (err, api) ->
      return callback err if err
      api.extract
        url: url
        format: 'json'
      , (err, data) ->
        if err
          return callback err
        if data.length is 1 and data[0].type is 'error'
          return callback new Error data[0].error_message

        out.beginGroup url
        out.send data
        out.endGroup()
        callback()

  noflo.helpers.MultiError c

  c
