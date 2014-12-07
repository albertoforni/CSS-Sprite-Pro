ENV = 'dev'
Utils =
  assert: (description, assertion) ->
    return if ENV is 'prod'

    unless assertion
      throw new Error description

  log: (klass, message) ->
    return if ENV is 'prod'

    console.log klass, message

  isNumber: (numbers...) ->
    allNumbers = true
    for num in numbers
      unless typeof num is 'number'
        allNumbers = false
        break

    allNumbers

module.exports = {Utils, ENV}
