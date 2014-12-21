ENV = 'dev'

###
Utilities

###
class Utils
  ###
  Make assertion, will throw error in dev mode and return void if prod

  @param [String]
  @param [Object]
  @option [string] environment type by def is the ENV value
  ###
  @assert: (description, assertion, ENV = ENV) ->
    return if ENV is 'prod'

    unless assertion
      throw new Error description

  ###
  Log a message in dev mode

  @param [String]
  @param [String]
  ###
  @log: (klass, message, ENV = ENV) ->
    return if ENV is 'prod'

    console.log klass, message

  ###
  Get the value of an object property. The property is a
  string like 'foo.baz'

  @param [Object]
  @param [String]
  ###
  @getProperty: (obj, path) ->
    Utils.assert 'obj must be an object', typeof obj is 'object'
    Utils.assert 'path must be a string and can contain dots to separate properties',
      /^[$_a-zA-Z]+([.\S]?\w)*$/.test(path)

    parts = path.split(".")
    last = parts.pop()
    l = parts.length
    i = 1
    current = parts[0]

    while (obj = obj[current]) and i < l
      current = parts[i]
      i++

    obj[last] if obj

  ###
  Get the value of an object property. The property is a
  string like 'foo.baz'

  @param [numbers] a list of numbers
  ###
  @isNumber: (numbers...) ->
    allNumbers = true
    for num in numbers
      unless typeof num is 'number'
        allNumbers = false
        break

    allNumbers

module.exports = {Utils, ENV}
