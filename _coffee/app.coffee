class App
  window.App = App

  #
  # private instance properties
  #

  # @_$downloadAnchor = {} download css and png
  # @_downloadFileName = ""

  # @_$saveAnchor = {} #save json file with all icons
  # @_saveFileName = ""

  # @_buttons = {} #actions like fit canvas to the images
  # @_reRenderCallback = null
  # @_iconOnloadCallback = null

  # @_canvas = {} #object that handles icons' display
  # @_code = {} #object that handles icons' code
  # @_icons = [] #array that stores all the icons

  # @_canvasIconTooltip = {} #inside canvas element, holds icon action to be shown on mouse hover. hidden by default

  #
  # constructor
  #
  constructor: (params) ->
    unless params and App.checkBrowserCompatibility()
      return false

    @_$downloadAnchor = $(params.download.anchor)
    @_downloadFileName = params.download.fileName
    @_$saveAnchor = $(params.save.anchor)
    @_saveFileName = params.save.fileName
    @_buttons = params.buttons
    @_reRenderCallback = params.reRenderCallback
    @_iconOnloadCallback = params.iconOnloadCallback

    @_canvas = new Canvas(params.canvas)
    @_code = new Code(params.code)
    @_icons = []

    @_canvasIconTooltip = params.canvasIconTooltip

    #drop icons events
    @_canvas.$area.on
      dragover: fileDrag
      dragleave: fileDrag
      drop: (e) =>
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
            reader.onload = do (file) =>
              (e) =>
                icon = new Image()
                icon.setSrc(e.target.result)
                icon.setName(file.name)

                icon.onload = =>
                  icon.setPosition(@_canvas.place(icon.width, icon.height))
                  @_icons.push(icon)
                  @_code.render(icon, files.length, false)
                  @_canvas.render(icon, files.length)
                  @_iconOnloadCallback()
            reader.readAsDataURL(file)
      click: (e) =>
        e.stopPropagation()
        @_canvasIconTooltip.$tooltip.off(".deleteIcon")

        mousePosition = @_canvas.getMousePos(e)

        for icon in @_icons
          if icon.left <= mousePosition.x <= icon.left + icon.width and icon.top <= mousePosition.y <= icon.top + icon.height
            selectedIcon = icon
            break

        if selectedIcon
          @_code.highlightElement(selectedIcon)
          @_canvasIconTooltip.$tooltip.removeClass("hidden").css
            left: @_canvasIconTooltip.addToLeft + selectedIcon.left + selectedIcon.width / 2
            top:  @_canvasIconTooltip.addToTop + selectedIcon.top + selectedIcon.height
            width: 150
            marginLeft: -75

          @_canvasIconTooltip.$tooltip.on "click.deleteIcon", @_canvasIconTooltip.buttons.deleteIcon, =>
            @_deleteIcon(selectedIcon)

          $("body").on "click.iconSelection", =>
            @_canvasIconTooltip.$tooltip.off(".deleteIcon")
            @_canvasIconTooltip.$tooltip.addClass("hidden")
            $(@).off(".iconSelection")

    #re-render icons
    $(document).on "rerender", (e, ui) =>
      for icon in @_icons
        newPosition = @_canvas.place(icon.width, icon.height)
        icon.left = newPosition.left
        icon.top = newPosition.top
        @_code.render(icon, @_icons.length, false, true)

      @_canvas.reRender(@_icons)

      @_reRenderCallback(e, ui)

    #initialize buttons behaviors
    $(document).ready =>
      $(@_buttons.fit).on "click", =>
        #fit canvas to the space occupied by the icons
        @_canvas.fit(@_icons)

      $(@_buttons.convert).on "click", =>
        #if the images name are properly formatted covert the to
        #pseudo-classes
        @_code.convert()

      $(@_buttons.clear).on "click", =>
        #clear canvas and code
        @_clear()

      $(@_buttons.save).on "click", =>
        #save the icons in a json file
        jsonToBeSaved = []
        for icon in @_icons
          jsonToBeSaved.push
            name: icon.name
            src: icon.src
            left: icon.left
            top: icon.top
            width: icon.width
            height: icon.height

        file = new Blob([JSON.stringify(jsonToBeSaved)], {type: "application/json;charset=utf-8;"});
        saveAs(file, @_saveFileName + ".json");

      #load json
      $(@_buttons.load).on "click", =>
        #load json file
        $(@_buttons.loadInput).val("").trigger("click")

      $(@_buttons.loadInput).on "change", (e) =>
        file = `this.files[0]`

        reader = new FileReader()
        reader.onload = (e) =>
          jsonFile = e.srcElement.result
          try
            loadedIcons = JSON.parse(jsonFile)
          catch error
            message.setMessage("App", "Your JSON file has some issues. #{error}", "production")

          #create the canvas
          @_clear()

          for loadedIcon in loadedIcons
            icon = new Image()
            icon.setSrc(loadedIcon.src)
            icon.setName(loadedIcon.name)

            icon.setPosition(@_canvas.place(icon.width, icon.height))
            @_icons.push(icon)
            @_code.render(icon, loadedIcons.length, false)
            @_canvas.render(icon, loadedIcons.length)
            @_iconOnloadCallback()

        reader.readAsText(file)

      @_$downloadAnchor.on "click", =>
        #download canvas and code
        canvasHtmlElement = @_canvas.$area[0]
        canvasHtmlElement.toBlob (blob) =>
          saveAs(blob, "#{@_downloadFileName}.png")

        codeText = @_code.$code.text()
        codeFile = new Blob([codeText], {type: "text/css;charset=utf-8;"})
        saveAs(codeFile, @_downloadFileName + "." + @_code.format)

  #
  # 'private' prototype methods
  #
  _clear: ->
    #clear canvas and code
    @_icons = []
    @_canvas.clear()
    @_code.clear()
    message.setMessage("app", "Now your project is empty", "production")

  _deleteIcon: (icon) ->
    @_icons = _.reject @_icons, (currentIcon) ->
      currentIcon.name == icon.name

    @_canvas.deleteIcon(icon)
    @_code.deteleIcon(icon)

    message.setMessage("app", "Icon #{icon.name} deleted", "production")

  #
  # private class methods
  #
  fileDrag = (e) ->
    # images enter or exit the drop area
    e.stopPropagation()
    e.preventDefault()
    e.target.className = if e.type == "dragover" then "hover" else ""

  #
  # public class methods
  #
  @checkBrowserCompatibility: ->
    if window.File and window.FileList and window.FileReader
      #add to JQuery events dataTransfer
      jQuery.event.props.push('dataTransfer')
    else
      message.setMessage("App", "Ops! your browser is not compatible with File, FileList or FileReader functionalities", "production")