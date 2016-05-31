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
  c.inPorts.add 'maxwidth',
    description: 'Maximum width for images in result'
    datatype: 'integer'
    default: 1000
  c.outPorts.add 'out',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: ['url']
    params: ['maxwidth']
    out: 'out'
    async: true
    forwardGroups: true
  , (url, groups, out, callback) ->
    unless c.token
      return callback new Error 'Embed.ly API token required'
    api = new embedly
      key: c.token
    params = JSON.parse JSON.stringify c.params
    params.url = url
    api.extract params, (err, data) ->
      if err
        return callback err
      if data.length is 1 and data[0].type is 'error'
        return callback new Error data[0].error_message

      data.provider = 'embed.ly'

      out.beginGroup url
      out.send data
      out.endGroup()
      callback()
