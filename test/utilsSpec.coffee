{Utils, ENV} = require '../app/coffee/utils'

describe 'Utils', ->
  describe '.assert', ->
    it 'throws an exception if the condition is false', ->
      expect(-> Utils.assert('5 == 6', 5 == 6)).to.throw(Error)

    it 'doesn\'t throw an error in in prod', ->
      result = Utils.assert('5 == 6', 5 == 6, 'prod')
      expect(result).to.be.equal(undefined)

    it 'returns undefined if the condition is true', ->
      result = Utils.assert('5 == 5', 5 == 5)

      expect(result).to.be.equal(undefined)

    it 'returns undefined if the condition is true even in prod', ->
      result = Utils.assert('5 == 5', 5 == 5, 'prod')

      expect(result).to.be.equal(undefined)

  describe '.log', ->
    originalLogFunc = console.log

    before ->
      # stub console.log
      console.log = (args...) -> "#{args.join(' ')}"

    after ->
      # revert the changes
      console.log = originalLogFunc

    it 'returns "a b"', ->
      result = Utils.log 'a', 'b'

      expect(result).to.be.equal('a b')

    it 'returns undefined in prod', ->
      result = Utils.log 'a', 'b', 'prod'

      expect(result).to.be.undefined

  describe '.getProperty', ->
    it 'throws an error if the first param is not an object', ->
      expect(-> Utils.getProperty('foo.blah')).to.throw(Error)
      expect(-> Utils.getProperty('object', 'foo.blah')).to.throw(Error)

    it 'throws an error if the the path param is not an string like baz.foo', ->
      expect(-> Utils.getProperty({}, 'foo blah')).to.throw(Error)
      expect(-> Utils.getProperty({}, '')).to.throw(Error)
      expect(-> Utils.getProperty({}, '^')).to.throw(Error)
      expect(-> Utils.getProperty({}, 5)).to.throw(Error)

    it 'returns the value of the corresponding property', ->
      obj =
        foo:
          baz: 5
          blah: 'hello'

      result = Utils.getProperty(obj, 'foo.baz')
      expect(result).to.be.equal(5)

      result = Utils.getProperty(obj, 'foo.blah')
      expect(result).to.be.equal('hello')


  describe '.isNumber', ->
    it 'returns false', ->
      expect(Utils.isNumber('5')).to.be.false
      expect(Utils.isNumber('5', 6)).to.be.false
      expect(Utils.isNumber(null, 6)).to.be.false
      expect(Utils.isNumber({}, [])).to.be.false

    it 'returns true', ->
      expect(Utils.isNumber(5)).to.be.true
      expect(Utils.isNumber(5, 6)).to.be.true
      expect(Utils.isNumber(5.5, 6)).to.be.true
      expect(Utils.isNumber(0, -10)).to.be.true
