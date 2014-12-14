{Utils, ENV} = require './Utils'
RSVP = require 'RSVP'

###
Handle the images placement

###
class Space
  ###
  The width of the space in px

  @property [Number]
  @private
  ###
  _spaceWidth: 0

  ###
  The height of the space in px

  @property [Number]
  @private
  ###
  _spaceHeight: 0

  ###
  It holds all the holes of space in using the following keys width, height, top, left

  @property [Array<Objects>]
  @private
  ###
  _emptySpaces: []

  ###
  The max width occupied

  @property [Number]
  @private
  ###
  _biggestWidth: 0 #in px, max width occupied by an icon

  ###
  The max height occupied

  @property [Number]
  @private
  ###
  _biggestHeight: 0

  ###
  @param [Number] width The width of the space
  @param [Number] height The height of the space
  ###
  constructor: (width, height) ->
    Utils.assert "width and height must be numbers", Utils.isNumber(width, height)
    @_spaceWidth = width
    @_spaceHeight = height

    # set the array in this instance!
    # do not push into the prototype
    @_emptySpaces = [
      width: width
      height: height
      top: 0
      left: 0
    ]

  ###
  Try to insert an element in the space

  @param [Number] elementWidth
  @param [Number] elementHeight
  @return [Promise] resolve(position), reject(message)
  ###
  place: (elementWidth, elementHeight) ->
    new RSVP.Promise (resolve, reject) =>

      position = null

      #check the first free hole
      for emptySpace, i in @_emptySpaces

        if elementHeight < emptySpace.height
          continue if elementWidth > emptySpace.width

          # in this emptySpace there is enough room both vertically and horizontally
          position =
            top: emptySpace.top
            left: emptySpace.left

          # create a new hole
          @_emptySpaces.splice i, 0, {
            width: emptySpace.width - elementWidth
            height: elementHeight
            top: emptySpace.top
            left: emptySpace.left + elementWidth
          }

          # modify the existing hole
          @_emptySpaces[i + 1] =
            width: emptySpace.width
            height: emptySpace.height - elementHeight
            top: emptySpace.top + elementHeight
            left: emptySpace.left

          break

        else if elementHeight == emptySpace.height
          continue if elementWidth > emptySpace.width

          # in this emptySpace there is enough room both vertically and horizontally
          position =
            top: emptySpace.top
            left: emptySpace.left

          # modify the existing hole
          @_emptySpaces[i] =
            width: emptySpace.width - elementWidth
            height: emptySpace.height
            top: emptySpace.top,
            left: emptySpace.left + elementWidth

          break

      unless position?
        message = "There isn't an hole big enough to contain the element"

        #unable to find a free hole
        Utils.log "Space", "There isn't an hole big enough to contain the element"

        return reject(message)

      # set the biggestHeight
      if position.top + elementHeight > @_biggestHeight
        @_biggestHeight = position.top + elementHeight

      # set the biggestWidth
      if position.left + elementWidth > @_biggestWidth
        @_biggestWidth = position.left + elementWidth

      resolve(position)

  ###
  clear the space and eventually set new with and height

  @param [Number] setWidth The new width of the space
  @param [Number] setHeight The new height of the space
  ###
  clear: (setWidth, setHeight) ->
    # reset biggest width and height
    @_biggestWidth = 0
    @_biggestHeight = 0

    # set new width and height if defined
    if setWidth? and setHeight?
      Utils.assert 'setWidth and setHeight must be numbers', Utils.isNumber(setWidth, setHeight)

      @_spaceWidth = setWidth
      @_spaceHeight = setHeight

    # reset emptySpaces
    @_emptySpaces = [
      width: @_spaceWidth
      height: @_spaceHeight
      top: 0
      left: 0
    ]

  ###
  Trim out the extra space fitting the space to the biggest width and height

  @return [Promise] resolve(null)
  ###
  fit: ->
    new RSVP.Promise (resolve) =>
      # fit the space to the images
      @_spaceWidth = @_biggestWidth
      @_spaceHeight = @_biggestHeight

      # modify emptySpaces
      for emptySpace, i in @_emptySpaces
        @_emptySpaces[i].width = @_spaceWidth - emptySpace.left if emptySpace.left + emptySpace.width > @_spaceWidth
        @_emptySpaces[i].height = @_spaceHeight - emptySpace.top if emptySpace.top + emptySpace.height > @_spaceHeight

      resolve()

  ###
  Get the width and the height of the space

  @return [Object] { width: [Number], height: [Number] }
  ###
  getArea: ->
    width: @_spaceWidth
    height: @_spaceHeight

module.exports = {Space}
