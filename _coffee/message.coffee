class Message
  window.Message = Message

  #
  # private instance properties
  #
  # @_$area = {}
  # @_$title = {}

  # @_mode = ""
  @_production: "production"
  @_debug: "debug"
  _modePermittedStatus: [Message._debug, Message._production]
  _messages: []

  #
  # constructor
  #
  constructor: (params) ->
    unless params
      return false

    @_$area = $(params.area)
    @_$title = $(params.title)
    if _.contains(@_modePermittedStatus, params.mode)
      @_mode = params.mode
    else
      @_mode = Message._production

  setMessage: (sender, message, status) ->
    unless sender and message
      return false

    if _.isUndefined(status) then status =  Message._production

    @_$title.hide() if @_messages.length is 0

    @_messages.push
      sender: sender
      message: message
      status: status

    if status is Message._production or (status is Message._debug and @_mode is Message._debug)
      $message = $("<p class='message'>#{message}</p>")
      if @_$area.find("p").length > 0
        @_$area.find("p").first().before($message)
      else
        @_$area.append($message)
      $message.hide().fadeIn()

  getMessage: (mode) ->
    if not mode or mode is Message._debug
      #return all messages [default]
      return @_messages
    else
      #return just the production messages
      productionMessages = []
      for message in @_messages
        productionMessages.push(message) if message is Message._production