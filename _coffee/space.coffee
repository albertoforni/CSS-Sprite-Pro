class Space
  #
  # private instance properties
  #
  spaceWidth = 0
  spaceHeight = 0
  emptySpaces = [] #array which holds all the holes of space in this way width, height, top, left
  biggestWidth = 0 #in px, max width occupied by an icon
  biggestHeight = 0 #in px, max height occupied by an icon

  #
  # constructor
  #
  constructor: (width, height)->
    unless width and height
      return false

    spaceWidth = width
    spaceHeight = height

    emptySpaces.push
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
    biggestWidth = 0
    biggestHeight = 0

    #set new width and height if defined
    if setWidth and setHeight
      spaceWidth = setWidth
      spaceHeight = setHeight

    #reset emptySpaces
    emptySpaces = [
      width: spaceWidth
      height: spaceHeight
      top: 0
      left: 0
    ]

    return true

  place: (elementWidth, elementHeight) ->
    # return the position in which draw the icon
    position = undefined
    for emptySpace, i in emptySpaces
      #check the first free hole

      if elementHeight < emptySpace.height
        if elementWidth > emptySpace.width then continue

        #in this emptySpace there is enough room both vertically and horizontally
        position =
          top: emptySpace.top
          left: emptySpace.left

        #create a new hole
        emptySpaces.splice(i, 0, {
          width: emptySpace.width - elementWidth
          height: elementHeight
          top: emptySpace.top
          left: emptySpace.left + elementWidth
        })

        #modify the existing hole
        emptySpaces[i + 1] =
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
        emptySpaces[i] =
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
    if position.top + elementHeight > biggestHeight
      biggestHeight = position.top + elementHeight

    #set the biggestWidth
    if position.left + elementWidth > biggestWidth
      biggestWidth = position.left + elementWidth

    return position

  fit: ->
    # fit the space to the images
    spaceWidth = biggestWidth
    message.setMessage("Space", "New space width: " + spaceWidth, "debug")
    spaceHeight = biggestHeight
    message.setMessage("Space", "New space height: " + spaceHeight, "debug")

    #modify emptySpaces
    for emptySpace, i in emptySpaces
      emptySpaces[i].width = spaceWidth - emptySpace.left if emptySpace.left + emptySpace.width > spaceWidth
      emptySpaces[i].height = spaceHeight - emptySpace.top if emptySpace.top + emptySpace.height > spaceHeight

    return @

  getArea: ->
    width: spaceWidth
    height: spaceHeight

  deleteElement: (left, top, width, height) ->
    #create a new hole in emptySpaces
    emptySpaces.unshift
      width: width
      height: height
      top: top
      left: left