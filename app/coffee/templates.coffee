{Utils, ENV} = require './utils'
_ = require 'underscore'

Templates =
  ###
  The templates

  @property [Object<Object<String>>]
  @private
  ###
  get: (path, params = {}) ->
    Utils.assert 'path must be a string', typeof path is 'string'

    template = Utils.getProperty(Templates, path)

    Utils.assert "Templates[#{path}] must be defined", template?

    Utils.assert 'params must be an Object', typeof params is 'object'

    template(params)

  ###
  The templates

  @property [Object<Object<String>>]
  @private
  ###
  css:
    start: _.template """
    i {
    \tbackground-image: url('<%= fileName %>.png');
    \tdisplay: inline-block;
    }\n"""

    block: _.template """
    i.<%= name %> {
    \tbackground-position: <%= left ? '-' + left + 'px' : '0' %> <%= top ? '-' + top + 'px' : '0' %>;
    \theight: <%= height %>px;
    \twidth: <%= width %>px;
    }\n"""

    end: _.template ''

  scss:
    start: _.template """
    i {
    \tbackground-image: url('<%= fileName %>.png');
    \tdisplay: inline-block;\n\n"""

    block: _.template """
    \t&.<%= name %> {
    \t\tbackground-position: <%= left ? '-' + left + 'px' : '0' %> <%= top ? '-' + top + 'px' : '0' %>;
    \t\theight: <%= height %>px;
    \t\twidth: <%= width %>px;
    \t}\n"""

    end: _.template """
    }"""

  less:
    start: _.template """
    i {
    \tbackground-image: url('<%= fileName %>.png');
    \tdisplay: inline-block;\n\n"""

    block: _.template """
    \t&.<%= name %> {
    \t\tbackground-position: <%= left ? '-' + left + 'px' : '0' %> <%= top ? '-' + top + 'px' : '0' %>;
    \t\theight: <%= height %>px;
    \t\twidth: <%= width %>px;
    \t}\n"""

    end: _.template """
    }"""

  sass:
    start: _.template """
    i
    \tbackground-image: url('<%= fileName %>.png')
    \tdisplay: inline-block\n\n"""

    block: _.template """
    \t&.<%= name %>
    \t\tbackground-position: <%= left ? '-' + left + 'px' : '0' %> <%= top ? '-' + top + 'px' : '0' %>
    \t\theight: <%= height %>px
    \t\twidth: <%= width %>px\n\n"""

    end: _.template ''

module.exports = {Templates}
