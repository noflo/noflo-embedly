noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Extract = require '../components/Extract.coffee'
else
  Extract = require 'noflo-embedly/components/Extract.js'

describe 'Extract component', ->
  c = null
  url = null
  key = null
  out = null
  beforeEach ->
    c = Extract.getComponent()
    url = noflo.internalSocket.createSocket()
    key = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.url.attach url
    c.inPorts.token.attach key
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an url port', ->
      chai.expect(c.inPorts.url).to.be.an 'object'
    it 'should have an token port', ->
      chai.expect(c.inPorts.token).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'extracting an article', ->
    it 'should return valid contents', (done) ->
      unless process.env.EMBEDLY_API_TOKEN
        chai.expect(false).to.equal true
        return done()

      extracted = 0
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'array'
        extracted += data.length
        chai.expect(data[0].title).to.equal 'The Dreams of the MeeGo Diaspora'
      out.on 'disconnect', ->
        chai.expect(extracted).to.equal 1
        done()

      key.send process.env.EMBEDLY_API_TOKEN
      url.send 'http://bergie.iki.fi/blog/meego-diaspora/'
