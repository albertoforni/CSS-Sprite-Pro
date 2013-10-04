class Message
  window.Message = Message

  #
  # private instance properties
  #
  $area = {}
  $title = {}

  mode = ""
  production = "production"
  debug = "debug"
  modePermittedStatus = [debug, production]
  messages = []

  #
  # constructor
  #
  constructor: (params) ->
    unless params
      return false

    $area = $(params.area)
    $title = $(params.title)
    if _.contains(modePermittedStatus, params.mode)
      mode = params.mode
    else
      mode = production

  setMessage: (sender, message, status) ->
    unless sender and message
      return false

    if _.isUndefined(status) then status =  production

    $title.hide() if messages.length is 0

    messages.push
      sender: sender
      message: message
      status: status

    if status is production or (status is debug and mode is debug)
      $message = $("<p class='message'>#{message}</p>")
      if $area.find("p").length > 0
        $area.find("p").first().before($message)
      else
        $area.append($message)
      $message.hide().fadeIn()

  getMessage: (mode) ->
    if not mode or mode is debug
      #return all messages [default]
      return messages
    else
      #return just the production messages
      productionMessages = []
      for message in messages
        productionMessages.push(message) if message is production