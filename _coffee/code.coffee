class Code
  #
  # private instance properties
  #
  _this = {}

  $area = {}
  $code = {}

  filter = {}
  data = {}

  $formatSelector = {}
  formatArray = ["css", "less", "scss", "sass"]
  template =
    css:
      start: "i {\n  background-image: url('cssspritepro.png');\n  display: inline-block;\n}\n"
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
  format = {}
  firstRowShown = false

  codeStack = []

  psudoClasses = ["link", "visited", "hover", "active"]

  #declare vars to be used inside the render
  numElementsCounter = 1
  addingArray = []

  #
  # constructor
  #
  constructor: (params) ->
    unless params
      return false

    _this = @

    $area = $(params.area)
    $code = $(params.code)
    filter = params.filter
    data = params.data
    $formatSelector = $(params.format)

    #find the selected format
    if _.contains(formatArray, $formatSelector.filter(filter).data(data))
      format = $formatSelector.filter(filter).data(data)
    else
      format = formatArray[0]

    #refactor code when the value of the format selector is changed
    $formatSelector.on "formatCodeSelected", ->
      format = $(@).find(filter).data(data)
      if firstRowShown
        _this.render(codeStack, undefined, true)

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
      @clear(true)

    html = ""

    if refactor is false
      #it means that I'm adding icons

      addingArray.push(element)

      if numElementsCounter < numElements
        #it means all icons haven't been loaded yet
        numElementsCounter++
      else
        #it means that all icons have been loaded
        $code[0].innerHTML = $code[0].innerHTML.substring(0, $code[0].innerHTML.length - 2)
        html = buildHtml(addingArray)
        codeStack = codeStack.concat(addingArray)

        #reset external vars
        numElementsCounter = 1
        addingArray = []

    else
      #it means that I'm refactoring the code (ex: from css to scss)
      $code[0].innerHTML = ""
      firstRowShown = false
      html = buildHtml(codeStack)

    #highlight code and when you're done display it
    #now I hardcoded "css" theme
    Rainbow.color html, "css", (highlighted_code) ->
      $code.append(highlighted_code)

  getArea: ->
    @$area

  convert: ->
    #transform the code to psudo-class selector

    newCodeStack = []

    _.each codeStack, (element)->
      for psudoClass in psudoClasses
        if element.name.indexOf("_" + psudoClass) != -1
          element.name = element.name.replace("_" + psudoClass, ":" + psudoClass )
          break
      newCodeStack.push(element)

    codeStack = newCodeStack

    @render(codeStack, codeStack.length, true, false)

    message.setMessage("code", "File's names converted to psudo-classes", "production")

  clear: (sure) ->
    if sure is true
      #reset all code
      codeStack = []
      $code[0].innerHTML = ""
      firstRowShown = false
    else
      message.setMessage("code", "You tried to clear the the code area, but you're not sure, right!?", "debug")
      return false

  #
  # private instance methods
  #
  buildHtml = (elements) ->
    unless $.isArray(elements)
      message.setMessage("code", "elments to render must be an array", "debug")

    templ = Handlebars.compile(template[format].block)
    html = ""

    if firstRowShown is false
      html += template[format].start
      firstRowShown = true

    html += templ(element) for element in elements

    return html += template[format].end