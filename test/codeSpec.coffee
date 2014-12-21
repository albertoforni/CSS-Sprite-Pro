{Code} = require '../app/coffee/code'
RSVP = require 'RSVP'

describe 'Code', ->
  describe '._template', ->
    it 'returns the expected css', ->

      expected = """
      i {
      \tbackground-image: url('test.png');
      \tdisplay: inline-block;
      }

      """

      result = Code._getTemplate('css', 'start', {fileName: 'test'})

      expect(result).to.be.equal(expected)
