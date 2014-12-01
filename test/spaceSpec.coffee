{Space} = require '../app/coffee/space'

describe 'Space', ->
  describe '#constructor', ->
    it 'creates an instance', ->
      space = new Space()
      expect(space).to.be.an('object')
