class Canvas

  #
  # private instance properties
  #

  $area = {}
  $background = {} #jQuery element which holds the background of the canvas

  resizeCallback = null
  stopCallback = null
  context = {} #canvas context must be 2d
  height = 0
  width = 0
  space = {} #object that handles the position of the icons inside the canvas. It is istanciated at render

  numElementsCounter = 1
  addingArray = []

  #
  # constructor
  #
  constructor: (ctx)->
    unless ctx
      return false

    $area = $(ctx.area)
    $background =  $(ctx.background)

    resizeCallback = ctx.resizeCallback
    stopCallback = ctx.stopCallback
    context = $area[0].getContext("2d")
    height = $area.height()
    width = $area.width()
    space = new Space(width, height)

    $area.resizable
      helper: "ui-resizable-helper"
      maxWidth: $area.parent().width() - parseInt($area.css("marginRight")) * 2
      handles: "se"
      resize: (e, ui) ->
        resizeCallback(e,ui)
      stop: (e,ui) =>
        #re-render icons
        @setWidth(ui.size.width)
        @setHeight(ui.size.height)
        @clear()
        $(document).trigger("rerender", ui)

        stopCallback(e,ui)


  #
  # public static methods
  #
  getArea: ->
    $area

  setHeight: (newHeight)->
    if newHeight
      height = newHeight
      $area.attr("height", height)

  setWidth: (newWidth)->
    if newWidth
      width = newWidth
      $area.attr("width", width)

  getHeight: ->
    height

  getWidth: ->
    width

  getContext: ->
    context

  getMousePos: (e) ->
    rect = $area[0].getBoundingClientRect()
    return {
      x: e.clientX - rect.left
      y: e.clientY - rect.top
    }

  place: (width, height) ->
    space.place(width,height)

  clear: () ->
    addingArray = []
    space.clear(width,height)
    context.clearRect(0, 0, width, height)

  drawImage: (IconsArray) ->
    #draw icons into the canvas
    for icon in IconsArray
      #use the canvas method
      @getContext().drawImage(icon, icon.left, icon.top)

  render: (Icon, numElements) ->
    #prepare to draw into the canvas
    unless Icon
      return false

    addingArray.push(Icon)
    if numElementsCounter < numElements
      # it means all the icons haven't been loaded yet
      numElementsCounter++
    else
      # all icons have been loaded
      @drawImage(addingArray)

    return @

  reRender: (Icons) ->
    # used when area is redrawn normally after a resize
    unless Icons
      return false

    @drawImage(Icons)

    return @

  fit: (Icons) ->
    #fit canvas size to the icons and redraw them

    space.fit()
    newSpaceArea = space.getArea()

    #retrieve old width and height
    oldWidth = width
    oldHeight = height

    #set new area
    @setWidth(newSpaceArea.width)
    @setHeight(newSpaceArea.height)

    $area.css
      width: width
      height: height

    #redraw icons
    @drawImage(Icons)

    #graphical settings
    newBackgroundWidth = $background.width() + width - oldWidth
    newBackgroundHeight = $background.height() + height - oldHeight

    $area.closest(".ui-wrapper").animate
      width: width
      height: height

    $background.animate
      width: newBackgroundWidth
      height: newBackgroundHeight

    message.setMessage("Canvas", "Now your icons are perfectly fitted into the image", "production")

  deleteIcon: (icon) ->
    #remove icon from adding array
    addingArray = _.reject addingArray, (currentIcon) ->
      currentIcon.name == icon.name

    #delete from space
    space.deleteElement(icon.left, icon.top, icon.width, icon.height)

    #delete from canvas
    context.clearRect(icon.left, icon.top, icon.width, icon.height)