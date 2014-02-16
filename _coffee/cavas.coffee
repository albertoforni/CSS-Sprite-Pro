class Canvas

  #
  # 'private' instance properties
  #

  # @_$background = {} #jQuery element which holds the background of the canvas

  # @_resizeCallback = null
  # @_stopCallback = null

  # @_height = 0
  # @_width = 0
  # @_space = {} #object that handles the position of the icons inside the canvas. It is istanciated at render

  # @_numElementsCounter = 1
  # @_addingArray = []

  #
  # public instance properties
  #

  # @$area = {}
  # @context = {} #canvas context must be 2d

  #
  # constructor
  #
  constructor: (ctx)->
    unless ctx
      return false

    @$area = $(ctx.area)
    @_$background =  $(ctx.background)

    @_resizeCallback = ctx.resizeCallback
    @_stopCallback = ctx.stopCallback
    @context = @$area[0].getContext("2d")
    @_height = @$area.height()
    @_width = @$area.width()
    @_space = new Space(@_width, @_height)

    @_numElementsCounter = 1
    @_addingArray = []

    @$area.resizable
      helper: "ui-resizable-helper"
      maxWidth: @$area.parent().width() - parseInt(@$area.css("marginRight")) * 2
      handles: "se"
      resize: (e, ui) =>
        @_resizeCallback(e,ui)
      stop: (e,ui) =>
        #re-render icons
        @setWidth(ui.size.width)
        @setHeight(ui.size.height)
        @clear()
        $(document).trigger("rerender", ui)

        @_stopCallback(e,ui)

  #
  # public instance methods
  #

  setHeight: (newHeight)->
    if newHeight
      @_height = newHeight
      @$area.attr("height", @_height)

  setWidth: (newWidth)->
    if newWidth
      @_width = newWidth
      @$area.attr("width", @_width)

  getMousePos: (e) ->
    rect = @$area[0].getBoundingClientRect()
    return {
      x: e.clientX - rect.left
      y: e.clientY - rect.top
    }

  place: (width, height) ->
    @_space.place(width,height)

  clear: () ->
    @_addingArray = []
    @_space.clear(@_width,@_height)
    @context.clearRect(0, 0, @_width, @_height)

  drawImage: (IconsArray) ->
    #draw icons into the canvas
    for icon in IconsArray
      #use the canvas method
      @context.drawImage(icon, icon.left, icon.top)

  render: (Icon, numElements) ->
    #prepare to draw into the canvas
    unless Icon
      return false

    @_addingArray.push(Icon)
    if @_numElementsCounter < numElements
      # it means all the icons haven't been loaded yet
      @_numElementsCounter++
    else
      # all icons have been loaded
      @drawImage(@_addingArray)

    return @

  reRender: (Icons) ->
    # used when area is redrawn normally after a resize
    unless Icons
      return false

    @drawImage(Icons)

    return @

  fit: (Icons) ->
    #fit canvas size to the icons and redraw them

    @_space.fit()
    newSpaceArea = @_space.getArea()

    #retrieve old width and height
    oldWidth = @_width
    oldHeight = @_height

    #set new area
    @setWidth(newSpaceArea.width)
    @setHeight(newSpaceArea.height)

    @$area.css
      width: @_width
      height: @_height

    #redraw icons
    @drawImage(Icons)

    #graphical settings
    newBackgroundWidth = @_$background.width() + @_width - oldWidth
    newBackgroundHeight = @_$background.height() + @_height - oldHeight

    @$area.closest(".ui-wrapper").animate
      width: @_width
      height: @_height

    @_$background.animate
      width: newBackgroundWidth
      height: newBackgroundHeight

    message.setMessage("Canvas", "Now your icons are perfectly fitted into the image", "production")

  deleteIcon: (icon) ->
    #remove icon from adding array
    @_addingArray = _.reject @_addingArray, (currentIcon) ->
      currentIcon.name == icon.name

    #delete from space
    @_space.deleteElement(icon.left, icon.top, icon.width, icon.height)

    #delete from canvas
    @context.clearRect(icon.left, icon.top, icon.width, icon.height)