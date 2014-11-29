class Code
  #
  # 'private' instance properties
  #

  # @_filter = {}
  # @_data = {}

  # @_$formatSelector = {}
  # @_fileName = ""

  # @_firstRowShown = false

  _codeStack: []

  #declare vars to be used inside the render
  _numElementsCounter: 1
  _addingArray: []

  #
  # 'private' class properties
  #
  @_formatArray: ["css", "less", "scss", "sass"]
  @_template:
    css:
      start: "i {\n  background-image: url('{{fileName}}.png');\n  display: inline-block;\n}\n"
      block: "i.{{name}}  {\n  background-position: {{#if left}}-{{/if}}{{left}}px {{#if top}}-{{/if}}{{top}}px;\n  height: {{height}}px;\n  width: {{width}}px;\n}\n"
      end: " \n"
    scss:
      start: "i {\n  background-image: url('cssspritepro.png');\n  display: inline-block;\n"
      block: "  &.{{name}} {\n   background-position: {{#if left}}-{{/if}}{{left}}px {{#if top}}-{{/if}}{{top}}px;\n   height: {{height}}px;\n   width: {{width}}px;\n  }\n"
      end: "}\n"
    less:
      start: "i {\n  background-image: url('cssspritepro.png');\n  display: inline-block;\n"
      block: "  &.{{name}} {\n   background-position: {{#if left}}-{{/if}}{{left}}px {{#if top}}-{{/if}}{{top}}px;\n   height: {{height}}px;\n   width: {{width}}px;\n  }\n"
      end: "}\n"
    sass:
      start: "i \n  background-image: url('cssspritepro.png');\n  display: inline-block\n"
      block: "  &.{{name}} \n   background-position: {{#if left}}-{{/if}}{{left}}px {{#if top}}-{{/if}}{{top}}px\n   height: {{height}}px\n   width: {{width}}px\n  \n"
      end: " \n"

  @_psudoClasses: ["link", "visited", "hover", "active"]

  #
  # public instance properties
  #

  # @$area = {}
  # @$code = {}
  # @format = {}

  #
  # constructor
  #
  constructor: (params) ->
    unless params
      return false

    @$area = $(params.area)
    @$code = $(params.code)

    @_fileName = params.fileName
    @_filter = params.filter
    @_data = params.data
    @_$formatSelector = $(params.format)

    @_firstRowShown = false

    #find the selected format
    if _.contains(Code._formatArray, @_$formatSelector.filter(@_filter).data(@_data))
      @format = @_$formatSelector.filter(@_filter).data(@_data)
    else
      @format = Code._formatArray[0]

    #refactor code when the value of the format selector is changed
    @_$formatSelector.on "formatCodeSelected", =>
      @format = `$(this).find(_this._filter).data(_this._data)` # `this` because I need to use javascript this
      if @_firstRowShown
        @render(@_codeStack, undefined, true)

    #create a condition to handel -0px issue
    Handlebars.registerHelper "if", (conditional, options) ->
      if(conditional)
        return options.fn(@)

  #
  # public instance methods
  #
  render: (element, numElements, refactor, clear) ->
    #render current icons code

    unless element
      return false

    if clear is true
      @clear()

    html = ""

    if refactor is false
      #it means that I'm adding icons

      @_addingArray.push(element)

      if @_numElementsCounter < numElements
        #it means all icons haven't been loaded yet
        @_numElementsCounter++
      else
        #it means that all icons have been loaded
        @$code[0].innerHTML = @$code[0].innerHTML.substring(0, @$code[0].innerHTML.length - 2)
        html = @_buildHtml(@_addingArray)
        @_codeStack = @_codeStack.concat(@_addingArray)

        #reset external vars
        @_numElementsCounter = 1
        @_addingArray = []

    else
      #it means that I'm refactoring the code (ex: from css to scss)
      @$code[0].innerHTML = ""
      @_firstRowShown = false
      html = @_buildHtml(@_codeStack)

    #highlight code and when you're done display it
    #now I hardcoded "css" theme
    Rainbow.color html, "css", (highlighted_code) =>
      @$code.append(highlighted_code)

  reRender: () ->
    @$code[0].innerHTML = ""
    @_firstRowShown = false
    html = @_buildHtml(@_codeStack)

    #highlight code and when you're done display it
    #now I hardcoded "css" theme
    Rainbow.color html, "css", (highlighted_code) =>
      @$code.append(highlighted_code)

  convert: ->
    #transform the code to psudo-class selector

    newCodeStack = []

    _.each @_codeStack, (element)->
      for psudoClass in Code._psudoClasses
        if element.name.indexOf("_" + psudoClass) != -1
          element.name = element.name.replace("_" + psudoClass, ":" + psudoClass )
          break
      newCodeStack.push(element)

    @_codeStack = newCodeStack

    @render(@_codeStack, @_codeStack.length, true, false)

    message.setMessage("code", "File's names converted to psudo-classes", "production")

  clear: () ->
    #reset all code
    @_codeStack = []
    @$code[0].innerHTML = ""
    @_firstRowShown = false

  highlightElement: (icon) ->
    @$code.find(".class").each () =>
      $icon = `$(this)`
      if icon.name == $icon.text().replace(".","")
        $icon.scrollView
          container: @$area
          complete: ->
            $icon.effect("highlight")

        return

  deteleIcon: (icon) ->
    @_codeStack = _.reject @_codeStack, (currentIcon) ->
      currentIcon.name == icon.name

    @reRender()

  #
  # private instance methods
  #
  _buildHtml: (elements) ->
    unless $.isArray(elements)
      message.setMessage("code", "elments to render must be an array", "debug")

    templ = Handlebars.compile(Code._template[@format].block)
    html = ""

    if @_firstRowShown is false
      html += Handlebars.compile(Code._template[@format].start)({fileName: @_fileName})
      @_firstRowShown = true

    html += templ(element) for element in elements

    return html += Code._template[@format].end