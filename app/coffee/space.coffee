class Space
  #
  # 'private' instance properties
  #
  _spaceWidth: 0
  _spaceHeight: 0
  _emptySpaces: [] #array which holds all the holes of space in this way width, height, top, left
  _biggestWidth: 0 #in px, max width occupied by an icon
  _biggestHeight: 0 #in px, max height occupied by an icon

  #
  # constructor
  #
  constructor: (width, height)->
    unless width and height
      return false

    @_spaceWidth = width
    @_spaceHeight = height

    @_emptySpaces.push
      width: width
      height: height
      top: 0
      left: 0

  #
  # public instance methods
  #
  clear: (setWidth, setHeight) ->
    # clear the space

    #reset biggest width and height
    @_biggestWidth = 0
    @_biggestHeight = 0

    #set new width and height if defined
    if setWidth and setHeight
      @_spaceWidth = setWidth
      @_spaceHeight = setHeight

    #reset emptySpaces
    @_emptySpaces = [
      width: @_spaceWidth
      height: @_spaceHeight
      top: 0
      left: 0
    ]

    return true

  place: (elementWidth, elementHeight) ->
    # return the position in which draw the icon
    position = undefined
    for emptySpace, i in @_emptySpaces
      #check the first free hole

      if elementHeight < emptySpace.height
        if elementWidth > emptySpace.width then continue

        #in this emptySpace there is enough room both vertically and horizontally
        position =
          top: emptySpace.top
          left: emptySpace.left

        #create a new hole
        @_emptySpaces.splice(i, 0, {
          width: emptySpace.width - elementWidth
          height: elementHeight
          top: emptySpace.top
          left: emptySpace.left + elementWidth
        })

        #modify the existing hole
        @_emptySpaces[i + 1] =
          width: emptySpace.width
          height: emptySpace.height - elementHeight
          top: emptySpace.top + elementHeight
          left: emptySpace.left

        break

      else if elementHeight == emptySpace.height
        if elementWidth > emptySpace.width then continue

        position =
          top: emptySpace.top
          left: emptySpace.left

        #modify the existing hole
        @_emptySpaces[i] =
          width: emptySpace.width - elementWidth
          height: emptySpace.height
          top: emptySpace.top,
          left: emptySpace.left + elementWidth

        break

    unless position
      #unable to find a free hole
      message.setMessage("Space", "Your image is too big for the actual canvas size. If you want to place that image you need to resize the cavans", "production")
      return false

    #set the biggestHeight
    if position.top + elementHeight > @_biggestHeight
      @_biggestHeight = position.top + elementHeight

    #set the biggestWidth
    if position.left + elementWidth > @_biggestWidth
      @_biggestWidth = position.left + elementWidth

    return position

  fit: ->
    # fit the space to the images
    @_spaceWidth = @_biggestWidth
    message.setMessage("Space", "New space width: " + @_spaceWidth, "debug")
    @_spaceHeight = @_biggestHeight
    message.setMessage("Space", "New space height: " + @_spaceHeight, "debug")

    #modify emptySpaces
    for emptySpace, i in @_emptySpaces
      @_emptySpaces[i].width = @_spaceWidth - emptySpace.left if emptySpace.left + emptySpace.width > @_spaceWidth
      @_emptySpaces[i].height = @_spaceHeight - emptySpace.top if emptySpace.top + emptySpace.height > @_spaceHeight

    return @

  getArea: ->
    width: @_spaceWidth
    height: @_spaceHeight

  deleteElement: (left, top, width, height) ->
    #create a new hole in emptySpaces
    @_emptySpaces.unshift
      width: width
      height: height
      top: top
      left: left