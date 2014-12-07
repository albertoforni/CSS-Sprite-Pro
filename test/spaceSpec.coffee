{Space} = require '../app/coffee/space'
RSVP = require 'RSVP'

describe 'Space', ->
  describe '#constructor', ->
    it 'it return an error if width and or height are not numbers', ->
      expect(-> throw new Error()).to.throw(Error)
      expect(-> throw new Error(1, null)).to.throw(Error)
      expect(-> throw new Error(null, 1)).to.throw(Error)
      expect(-> throw new Error("1", "1")).to.throw(Error)

    it 'creates an instance of Space', ->
      space = new Space(200, 300)
      expect(space).to.be.an.instanceOf(Space)

    it 'sets the correct values', ->
      space = new Space(350, 300)

      expect(space._spaceWidth).to.be.equal(350)
      expect(space._spaceHeight).to.be.equal(300)
      expect(space._biggestWidth).to.be.equal(0)
      expect(space._biggestHeight).to.be.equal(0)
      expect(space._emptySpaces).to.be.deep.equal([
        width: 350
        height: 300
        top: 0
        left: 0
      ])

  describe '#place', ->
    space = null

    beforeEach ->
      space = new Space(100, 100)

    it 'returns a promise', (done) ->
      promise = space.place(30, 30)

      promise.then ->
        expect(promise).to.be.an.instanceOf(RSVP.Promise)
        done()

    it 'resolves with position 0, 0', (done) ->
      promise = space.place(30, 30)

      promise.then (position) ->
        expect(position.top).to.be.equal(0)
        expect(position.left).to.be.equal(0)
        expect(space._biggestWidth).to.be.equal(30)
        expect(space._biggestHeight).to.be.equal(30)
        done()

    it 'rejects with an Error', (done) ->
      promise = space.place(150, 30)

      promise.catch (error) ->
        expect(error).to.be.equal("There isn't an hole big enough to contain the element")
        done()

    it 'returns the second element with position top 0, left 30', (done) ->
      valuesToPlace = [
        [30, 30]
        [40, 30]
      ]

      valuesToPlace.reduce (cur, next) ->
        cur.then -> space.place(next...)
      , RSVP.resolve()
      .then (lastElement) ->
        expect(lastElement.top).to.be.equal(0)
        expect(lastElement.left).to.be.equal(30)
        expect(space._biggestWidth).to.be.equal(70)
        expect(space._biggestHeight).to.be.equal(30)
        done()

    it 'slices the emptySpace array', (done) ->
      expectEmptySpaces = [
        {
          width: 100 - 30 - 40
          height: 30
          top: 0
          left: 30 + 40
        }
        {
          width: 100
          height: 100 - 30
          top: 30
          left: 0
        }
      ]

      valuesToPlace = [
        [30, 30]
        [40, 30]
      ]

      valuesToPlace.reduce (cur, next) ->
        cur.then -> space.place(next...)
      , RSVP.resolve()
      .then ->
        expect(space._emptySpaces)
        .to.be.deep.equal(expectEmptySpaces)

        done()

  describe '#clear', ->
    space = null

    beforeEach ->
      space = new Space(430, 540)

    it 'throws an error if width and height are not numbers', ->
      expect(-> space.clear('5', 4)).to.throw(Error)

    it 'sets all the instance variable to the default value', (done) ->
      space.place(40, 40)
      .then ->

        space.clear()

        expect(space._spaceWidth).to.be.equal(430)
        expect(space._spaceHeight).to.be.equal(540)
        expect(space._biggestWidth).to.be.equal(0)
        expect(space._biggestHeight).to.be.equal(0)
        expect(space._emptySpaces).to.be.deep.equal([
          width: 430
          height: 540
          top: 0
          left: 0
        ])
        done()

    it 'sets all the instance variable to the default value, and new dimensions 400, 500', (done) ->
      space.place(40, 40)
      .then ->

        space.clear(400, 500)

        expect(space._spaceWidth).to.be.equal(400)
        expect(space._spaceHeight).to.be.equal(500)
        expect(space._biggestWidth).to.be.equal(0)
        expect(space._biggestHeight).to.be.equal(0)
        expect(space._emptySpaces).to.be.deep.equal([
          width: 400
          height: 500
          top: 0
          left: 0
        ])
        done()

  describe '#fit', ->
    space = null

    beforeEach ->
      space = new Space(200, 200)

    it 'returns a promise', (done) ->
      promise = space.fit()

      promise.then ->
        expect(promise).to.be.an.instanceOf(RSVP.Promise)
        done()

    it 'sets the space to 75, 105', (done) ->

      valuesToPlace = [
        [75, 40]
        [40, 65]
      ]

      valuesToPlace.reduce (cur, next) ->
        cur.then -> space.place(next...)
      , RSVP.resolve()
      .then ->
        space.fit()
      .then ->
        expect(space._biggestWidth).to.be.equal(75)
        expect(space._biggestHeight).to.be.equal(105)
        expect(space._spaceWidth).to.be.equal(75)
        expect(space._spaceHeight).to.be.equal(105)
        done()

  describe '#getArea', ->
    space = null

    beforeEach ->
      space = new Space(150, 200)

    it 'returns a 150, 200', ->
      area = space.getArea()

      expect(area.width).to.be.equal(150)
      expect(area.height).to.be.equal(200)

    it 'returns a 75, 105', (done) ->
      valuesToPlace = [
        [75, 40]
        [40, 65]
      ]

      valuesToPlace.reduce (cur, next) ->
        cur.then -> space.place(next...)
      , RSVP.resolve()
      .then ->
        space.fit()
      .then ->
        area = space.getArea()

        expect(area.width).to.be.equal(75)
        expect(area.height).to.be.equal(105)
        done()
