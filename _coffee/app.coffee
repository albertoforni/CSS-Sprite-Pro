class App
  window.App = App

  #
  # private instance properties
  #

  $downloadAnchor = {} #download css and png
  downloadFileName = ""

  $saveAnchor = {} #save json file with all icons
  saveFileName = ""

  buttons = {} #actions like fit canvas to the images
  reRenderCallback = null
  iconOnloadCallback = null

  canvas = {} #object that handles icons' display
  code = {} #object that handles icons' code
  icons = [] #array that stores all the icons

  canvasIconTooltip = {} #inside canvas element, holds icon action to be shown on mouse hover. hidden by default

  #
  # constructor
  #
  constructor: (params) ->
    unless params and App.checkBrowserCompatibility()
      return false

    $downloadAnchor = $(params.download.anchor)
    downloadFileName = params.download.fileName
    $saveAnchor = $(params.save.anchor)
    saveFileName = params.save.fileName
    buttons = params.buttons
    reRenderCallback = params.reRenderCallback
    iconOnloadCallback = params.iconOnloadCallback

    canvas = new Canvas(params.canvas)
    code = new Code(params.code)

    canvasIconTooltip = params.canvasIconTooltip

    #drop icons events
    canvas.getArea().on
      dragover: fileDrag
      dragleave: fileDrag
      drop: parseFile
      click: (e) ->
        e.stopPropagation()
        canvasIconTooltip.$tooltip.off(".deleteIcon")

        mousePosition = canvas.getMousePos(e)

        for icon in icons
          if icon.left <= mousePosition.x <= icon.left + icon.width and icon.top <= mousePosition.y <= icon.top + icon.height
            selectedIcon = icon
            break

        if selectedIcon
          code.highlightElement(selectedIcon)
          canvasIconTooltip.$tooltip.removeClass("hidden").css
            left: canvasIconTooltip.addToLeft + selectedIcon.left + selectedIcon.width / 2
            top:  canvasIconTooltip.addToTop + selectedIcon.top + selectedIcon.height
            width: 150
            marginLeft: -75

          canvasIconTooltip.$tooltip.on "click.deleteIcon", canvasIconTooltip.buttons.deleteIcon, ->
            deleteIcon(selectedIcon)

          $("body").on "click.iconSelection", ->
            canvasIconTooltip.$tooltip.off(".deleteIcon")
            canvasIconTooltip.$tooltip.addClass("hidden")
            $(@).off(".iconSelection")

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

      $(buttons.save).on "click", =>
        #save the icons in a json file
        jsonToBeSaved = []
        for icon in icons
          jsonToBeSaved.push
            name: icon.name
            src: icon.src
            left: icon.left
            top: icon.top
            width: icon.width
            height: icon.height

        file = new Blob([JSON.stringify(jsonToBeSaved)], {type: "application/json;charset=utf-8;"});
        saveAs(file, saveFileName + ".json");

      #load json
      $(buttons.load).on "click", =>
        #load json file
        $(buttons.loadInput).trigger("click")

      $(buttons.loadInput).on "change", (e) ->
        file = $(@)[0].files[0]

        reader = new FileReader()
        reader.onload = (e) ->
          jsonFile = e.srcElement.result
          try
            loadedIcons = JSON.parse(jsonFile)
          catch error
            message.setMessage("App", "Your JSON file has some issues. #{error}", "production")

          #create the canvas
          clear()

          for loadedIcon in loadedIcons
            icon = new Image()
            icon.setSrc(loadedIcon.src)
            icon.setName(loadedIcon.name)

            icon.setPosition(canvas.place(icon.width, icon.height))
            icons.push(icon)
            code.render(icon, loadedIcons.length, false)
            canvas.render(icon, loadedIcons.length)
            iconOnloadCallback?()

        reader.readAsText(file)

      $downloadAnchor.on "click", ->
        #download canvas and code
        canvasHtmlElement = canvas.getArea()[0]
        canvasHtmlElement.toBlob (blob) ->
          saveAs(blob, "#{downloadFileName}.png")

        codeText = code.getCode().text()
        codeFile = new Blob([codeText], {type: "text/css;charset=utf-8;"})
        saveAs(codeFile, downloadFileName + "." + code.getFormat())

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
              canvas.render(icon, files.length)
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

  deleteIcon = (icon) ->
    icons = _.reject icons, (currentIcon) ->
      currentIcon.name == icon.name

    canvas.deleteIcon(icon)
    code.deteleIcon(icon)

    message.setMessage("app", "Icon #{icon.name} deleted", "production")

  #
  # public static methods
  #
  @checkBrowserCompatibility: ->
    if window.File and window.FileList and window.FileReader
      #add to JQuery events dataTransfer
      jQuery.event.props.push('dataTransfer')
    else
      message.setMessage("App", "Ops! your browser is not compatible with File, FileList or FileReader functionalities", "production")