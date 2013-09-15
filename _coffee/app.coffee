class App
  window.App = App

  #
  # private instance properties
  #

  $downloadAnchor = {}
  downloadFileName = {}
  buttons = {} #actions like fit canvas to the images
  reRenderCallback = null
  iconOnloadCallback = null

  canvas = {} #object that handles icons' display
  code = {} #object that handles icons' code
  icons = [] #array that stores all the icons

  #
  # constructor
  #
  constructor: (params) ->
    unless params and App.checkBrowserCompatibility()
      return false

    $downloadAnchor = $(params.download.anchor)
    downloadFileName = params.download.fileName
    buttons = params.buttons
    reRenderCallback = params.reRenderCallback
    iconOnloadCallback = params.iconOnloadCallback

    canvas = new Canvas(params.canvas)
    code = new Code(params.code)

    #drop icons events
    canvas.getArea().on
      dragover: fileDrag
      dragleave: fileDrag
      drop: parseFile

    #re-render icons
    $(document).on "rerender", (e, ui) ->
      for icon in icons
        newPosition = canvas.place(icon.width, icon.height)
        icon.left = newPosition.left
        icon.top = newPosition.top
        code.render(icon, icons.length, false, true)

      canvas.reRender(icons)

      reRenderCallback?(e, ui)

    #initialize buttons behaviors
    $(document).ready ->
      $(buttons.fit).on "click", =>
        #fit canvas to the space occupied by the icons
        fit()

      $(buttons.convert).on "click", =>
        #if the images name are properly formatted covert the to
        #pseudo-classes
        convert()

      $(buttons.clear).on "click", =>
        #clear canvas and code
        clear()

    #initialize copy to clipboard of code
    copyAllLink = new ZeroClipboard $(params.download.copyAll), {
      moviePath: './resources/ZeroClipboard.swf'
      hoverClass: "hover"
    }

    copyAllLink.on 'complete', ->
      message.setMessage("App", "Copied text to clipboard", "production")

  #
  # private instance methods
  #
  fileDrag = (e) ->
    # images enter or exit the drop area
    e.stopPropagation()
    e.preventDefault()
    e.target.className = if e.type == "dragover" then "hover" else ""

  parseFile = (e) ->
    # parse the droped images
    e.stopPropagation()
    e.preventDefault()

    files = e.dataTransfer.files

    fileDrag(e)

    #load images and render them
    for file in files
      reader = new FileReader()
      if file.type.indexOf("image") == 0
        #only images are allowed
        reader.onload = do (file) ->
          (e) ->
            icon = new Image()
            icon.setSrc(e.target.result)
            icon.setName(file.name)

            icon.onload = ->
              icon.setPosition(canvas.place(icon.width, icon.height))
              icons.push(icon)
              code.render(icon, files.length, false)
              canvas.render(icon, files.length, $downloadAnchor, downloadFileName)
              iconOnloadCallback?()
        reader.readAsDataURL(file)

  fit = ->
    #fit canvas to current icons dimensions and positions
    canvas.fit(icons)

  convert = ->
    #if the images name are properly formatted covert the to
    #pseudo-classes
    code.convert()

  clear = ->
    #clear canvas and code
    icons = []
    canvas.clear(true)
    code.clear(true)
    message.setMessage("app", "Now your project is empty", "production")

  #
  # public static methods
  #
  @checkBrowserCompatibility: ->
    if window.File and window.FileList and window.FileReader
      #add to JQuery events dataTransfer
      jQuery.event.props.push('dataTransfer')
    else
      message.setMessage("App", "Ops! your browser is not compatible with File, FileList or FileReader functionalities", "production")