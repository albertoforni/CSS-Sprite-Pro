(function() {
  var App, Canvas, Code, Message, Space;

  App = (function() {
    var fileDrag;

    window.App = App;

    function App(params) {
      if (!(params && App.checkBrowserCompatibility())) {
        return false;
      }
      this._$downloadAnchor = $(params.download.anchor);
      this._downloadFileName = params.download.fileName;
      this._$saveAnchor = $(params.save.anchor);
      this._saveFileName = params.save.fileName;
      this._buttons = params.buttons;
      this._reRenderCallback = params.reRenderCallback;
      this._iconOnloadCallback = params.iconOnloadCallback;
      this._canvas = new Canvas(params.canvas);
      this._code = new Code(params.code);
      this._icons = [];
      this._canvasIconTooltip = params.canvasIconTooltip;
      this._canvas.$area.on({
        dragover: fileDrag,
        dragleave: fileDrag,
        drop: (function(_this) {
          return function(e) {
            var file, files, reader, _i, _len, _results;
            e.stopPropagation();
            e.preventDefault();
            files = e.dataTransfer.files;
            fileDrag(e);
            _results = [];
            for (_i = 0, _len = files.length; _i < _len; _i++) {
              file = files[_i];
              reader = new FileReader();
              if (file.type.indexOf("image") === 0) {
                reader.onload = (function(file) {
                  return function(e) {
                    var icon;
                    icon = new Image();
                    icon.setSrc(e.target.result);
                    icon.setName(file.name);
                    return icon.onload = function() {
                      icon.setPosition(_this._canvas.place(icon.width, icon.height));
                      _this._icons.push(icon);
                      _this._code.render(icon, files.length, false);
                      _this._canvas.render(icon, files.length);
                      return _this._iconOnloadCallback();
                    };
                  };
                })(file);
                _results.push(reader.readAsDataURL(file));
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          };
        })(this),
        click: (function(_this) {
          return function(e) {
            var icon, mousePosition, selectedIcon, _i, _len, _ref, _ref1, _ref2;
            e.stopPropagation();
            _this._canvasIconTooltip.$tooltip.off(".deleteIcon");
            mousePosition = _this._canvas.getMousePos(e);
            _ref = _this._icons;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              icon = _ref[_i];
              if ((icon.left <= (_ref1 = mousePosition.x) && _ref1 <= icon.left + icon.width) && (icon.top <= (_ref2 = mousePosition.y) && _ref2 <= icon.top + icon.height)) {
                selectedIcon = icon;
                break;
              }
            }
            if (selectedIcon) {
              _this._code.highlightElement(selectedIcon);
              _this._canvasIconTooltip.$tooltip.removeClass("l-hidden").css({
                left: _this._canvasIconTooltip.addToLeft + selectedIcon.left + selectedIcon.width / 2,
                top: _this._canvasIconTooltip.addToTop + selectedIcon.top + selectedIcon.height,
                width: 150,
                marginLeft: -75
              });
              _this._canvasIconTooltip.$tooltip.on("click.deleteIcon", _this._canvasIconTooltip.buttons.deleteIcon, function() {
                return _this._deleteIcon(selectedIcon);
              });
              return $("body").on("click.iconSelection", function() {
                _this._canvasIconTooltip.$tooltip.off(".deleteIcon");
                _this._canvasIconTooltip.$tooltip.addClass("l-hidden");
                return $(_this).off(".iconSelection");
              });
            }
          };
        })(this)
      });
      $(document).on("rerender", (function(_this) {
        return function(e, ui) {
          var icon, newPosition, _i, _len, _ref;
          _ref = _this._icons;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            icon = _ref[_i];
            newPosition = _this._canvas.place(icon.width, icon.height);
            icon.left = newPosition.left;
            icon.top = newPosition.top;
            _this._code.render(icon, _this._icons.length, false, true);
          }
          _this._canvas.reRender(_this._icons);
          return _this._reRenderCallback(e, ui);
        };
      })(this));
      $(document).ready((function(_this) {
        return function() {
          $(_this._buttons.fit).on("click", function() {
            return _this._canvas.fit(_this._icons);
          });
          $(_this._buttons.convert).on("click", function() {
            return _this._code.convert();
          });
          $(_this._buttons.clear).on("click", function() {
            return _this._clear();
          });
          $(_this._buttons.save).on("click", function() {
            var file, icon, jsonToBeSaved, _i, _len, _ref;
            jsonToBeSaved = [];
            _ref = _this._icons;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              icon = _ref[_i];
              jsonToBeSaved.push({
                name: icon.name,
                src: icon.src,
                left: icon.left,
                top: icon.top,
                width: icon.width,
                height: icon.height
              });
            }
            file = new Blob([JSON.stringify(jsonToBeSaved)], {
              type: "application/json;charset=utf-8;"
            });
            return saveAs(file, _this._saveFileName + ".json");
          });
          $(_this._buttons.load).on("click", function() {
            return $(_this._buttons.loadInput).val("").trigger("click");
          });
          $(_this._buttons.loadInput).on("change", function(e) {
            var file, reader;
            file = this.files[0];
            reader = new FileReader();
            reader.onload = function(e) {
              var error, icon, jsonFile, loadedIcon, loadedIcons, _i, _len, _results;
              jsonFile = e.srcElement.result;
              try {
                loadedIcons = JSON.parse(jsonFile);
              } catch (_error) {
                error = _error;
                message.setMessage("App", "Your JSON file has some issues. " + error, "production");
              }
              _this._clear();
              _results = [];
              for (_i = 0, _len = loadedIcons.length; _i < _len; _i++) {
                loadedIcon = loadedIcons[_i];
                icon = new Image();
                icon.setSrc(loadedIcon.src);
                icon.setName(loadedIcon.name);
                icon.setPosition(_this._canvas.place(icon.width, icon.height));
                _this._icons.push(icon);
                _this._code.render(icon, loadedIcons.length, false);
                _this._canvas.render(icon, loadedIcons.length);
                _results.push(_this._iconOnloadCallback());
              }
              return _results;
            };
            return reader.readAsText(file);
          });
          return _this._$downloadAnchor.on("click", function() {
            var canvasHtmlElement, codeFile, codeText;
            canvasHtmlElement = _this._canvas.$area[0];
            canvasHtmlElement.toBlob(function(blob) {
              return saveAs(blob, "" + _this._downloadFileName + ".png");
            });
            codeText = _this._code.$code.text();
            codeFile = new Blob([codeText], {
              type: "text/css;charset=utf-8;"
            });
            return saveAs(codeFile, _this._downloadFileName + "." + _this._code.format);
          });
        };
      })(this));
    }

    App.prototype._clear = function() {
      this._icons = [];
      this._canvas.clear();
      this._code.clear();
      return message.setMessage("app", "Now your project is empty", "production");
    };

    App.prototype._deleteIcon = function(icon) {
      this._icons = _.reject(this._icons, function(currentIcon) {
        return currentIcon.name === icon.name;
      });
      this._canvas.deleteIcon(icon);
      this._code.deteleIcon(icon);
      return message.setMessage("app", "Icon " + icon.name + " deleted", "production");
    };

    fileDrag = function(e) {
      e.stopPropagation();
      e.preventDefault();
      return e.target.className = e.type === "dragover" ? "canvas-element ui-resizable is-hover" : "canvas-element ui-resizable";
    };

    App.checkBrowserCompatibility = function() {
      if (window.File && window.FileList && window.FileReader) {
        return jQuery.event.props.push('dataTransfer');
      } else {
        return message.setMessage("App", "Ops! your browser is not compatible with File, FileList or FileReader functionalities", "production");
      }
    };

    return App;

  })();

  Canvas = (function() {
    Canvas.prototype._numElementsCounter = 1;

    Canvas.prototype._addingArray = [];

    function Canvas(ctx) {
      if (!ctx) {
        return false;
      }
      this.$area = $(ctx.area);
      this._$background = $(ctx.background);
      this._resizeCallback = ctx.resizeCallback;
      this._stopCallback = ctx.stopCallback;
      this.context = this.$area[0].getContext("2d");
      this._height = this.$area.height();
      this._width = this.$area.width();
      this._space = new Space(this._width, this._height);
      this.$area.resizable({
        helper: "ui-resizable-helper",
        maxWidth: this.$area.parent().width() - parseInt(this.$area.css("marginRight")) * 2,
        handles: "se",
        resize: (function(_this) {
          return function(e, ui) {
            return _this._resizeCallback(e, ui);
          };
        })(this),
        stop: (function(_this) {
          return function(e, ui) {
            _this.setWidth(ui.size.width);
            _this.setHeight(ui.size.height);
            _this.clear();
            $(document).trigger("rerender", ui);
            return _this._stopCallback(e, ui);
          };
        })(this)
      });
    }

    Canvas.prototype.setHeight = function(newHeight) {
      if (newHeight) {
        this._height = newHeight;
        return this.$area.attr("height", this._height);
      }
    };

    Canvas.prototype.setWidth = function(newWidth) {
      if (newWidth) {
        this._width = newWidth;
        return this.$area.attr("width", this._width);
      }
    };

    Canvas.prototype.getMousePos = function(e) {
      var rect;
      rect = this.$area[0].getBoundingClientRect();
      return {
        x: e.clientX - rect.left,
        y: e.clientY - rect.top
      };
    };

    Canvas.prototype.place = function(width, height) {
      return this._space.place(width, height);
    };

    Canvas.prototype.clear = function() {
      this._addingArray = [];
      this._space.clear(this._width, this._height);
      return this.context.clearRect(0, 0, this._width, this._height);
    };

    Canvas.prototype.drawImage = function(IconsArray) {
      var icon, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = IconsArray.length; _i < _len; _i++) {
        icon = IconsArray[_i];
        _results.push(this.context.drawImage(icon, icon.left, icon.top));
      }
      return _results;
    };

    Canvas.prototype.render = function(Icon, numElements) {
      if (!Icon) {
        return false;
      }
      this._addingArray.push(Icon);
      if (this._numElementsCounter < numElements) {
        this._numElementsCounter++;
      } else {
        this.drawImage(this._addingArray);
      }
      return this;
    };

    Canvas.prototype.reRender = function(Icons) {
      if (!Icons) {
        return false;
      }
      this.drawImage(Icons);
      return this;
    };

    Canvas.prototype.fit = function(Icons) {
      var newBackgroundHeight, newBackgroundWidth, newSpaceArea, oldHeight, oldWidth;
      this._space.fit();
      newSpaceArea = this._space.getArea();
      oldWidth = this._width;
      oldHeight = this._height;
      this.setWidth(newSpaceArea.width);
      this.setHeight(newSpaceArea.height);
      this.$area.css({
        width: this._width,
        height: this._height
      });
      this.drawImage(Icons);
      newBackgroundWidth = this._$background.width() + this._width - oldWidth;
      newBackgroundHeight = this._$background.height() + this._height - oldHeight;
      this.$area.closest(".ui-wrapper").animate({
        width: this._width,
        height: this._height
      });
      this._$background.animate({
        width: newBackgroundWidth,
        height: newBackgroundHeight
      });
      return message.setMessage("Canvas", "Now your icons are perfectly fitted into the image", "production");
    };

    Canvas.prototype.deleteIcon = function(icon) {
      this._addingArray = _.reject(this._addingArray, function(currentIcon) {
        return currentIcon.name === icon.name;
      });
      this._space.deleteElement(icon.left, icon.top, icon.width, icon.height);
      return this.context.clearRect(icon.left, icon.top, icon.width, icon.height);
    };

    return Canvas;

  })();

  Code = (function() {
    Code.prototype._codeStack = [];

    Code.prototype._numElementsCounter = 1;

    Code.prototype._addingArray = [];

    Code._formatArray = ["css", "less", "scss", "sass"];

    Code._template = {
      css: {
        start: "i {\n  background-image: url('{{fileName}}.png');\n  display: inline-block;\n}\n",
        block: "i.{{name}}  {\n  background-position: {{#if left}}-{{/if}}{{left}}px {{#if top}}-{{/if}}{{top}}px;\n  height: {{height}}px;\n  width: {{width}}px;\n}\n",
        end: " \n"
      },
      scss: {
        start: "i {\n  background-image: url('cssspritepro.png');\n  display: inline-block;\n",
        block: "  &.{{name}} {\n   background-position: {{#if left}}-{{/if}}{{left}}px {{#if top}}-{{/if}}{{top}}px;\n   height: {{height}}px;\n   width: {{width}}px;\n  }\n",
        end: "}\n"
      },
      less: {
        start: "i {\n  background-image: url('cssspritepro.png');\n  display: inline-block;\n",
        block: "  &.{{name}} {\n   background-position: {{#if left}}-{{/if}}{{left}}px {{#if top}}-{{/if}}{{top}}px;\n   height: {{height}}px;\n   width: {{width}}px;\n  }\n",
        end: "}\n"
      },
      sass: {
        start: "i \n  background-image: url('cssspritepro.png');\n  display: inline-block\n",
        block: "  &.{{name}} \n   background-position: {{#if left}}-{{/if}}{{left}}px {{#if top}}-{{/if}}{{top}}px\n   height: {{height}}px\n   width: {{width}}px\n  \n",
        end: " \n"
      }
    };

    Code._psudoClasses = ["link", "visited", "hover", "active"];

    function Code(params) {
      if (!params) {
        return false;
      }
      this.$area = $(params.area);
      this.$code = $(params.code);
      this._fileName = params.fileName;
      this._filter = params.filter;
      this._data = params.data;
      this._$formatSelector = $(params.format);
      this._firstRowShown = false;
      if (_.contains(Code._formatArray, this._$formatSelector.filter(this._filter).data(this._data))) {
        this.format = this._$formatSelector.filter(this._filter).data(this._data);
      } else {
        this.format = Code._formatArray[0];
      }
      this._$formatSelector.on("formatCodeSelected", (function(_this) {
        return function() {
          _this.format = $(this).find(_this._filter).data(_this._data);
          if (_this._firstRowShown) {
            return _this.render(_this._codeStack, void 0, true);
          }
        };
      })(this));
      Handlebars.registerHelper("if", function(conditional, options) {
        if (conditional) {
          return options.fn(this);
        }
      });
    }

    Code.prototype.render = function(element, numElements, refactor, clear) {
      var html;
      if (!element) {
        return false;
      }
      if (clear === true) {
        this.clear();
      }
      html = "";
      if (refactor === false) {
        this._addingArray.push(element);
        if (this._numElementsCounter < numElements) {
          this._numElementsCounter++;
        } else {
          this.$code[0].innerHTML = this.$code[0].innerHTML.substring(0, this.$code[0].innerHTML.length - 2);
          html = this._buildHtml(this._addingArray);
          this._codeStack = this._codeStack.concat(this._addingArray);
          this._numElementsCounter = 1;
          this._addingArray = [];
        }
      } else {
        this.$code[0].innerHTML = "";
        this._firstRowShown = false;
        html = this._buildHtml(this._codeStack);
      }
      return Rainbow.color(html, "css", (function(_this) {
        return function(highlighted_code) {
          return _this.$code.append(highlighted_code);
        };
      })(this));
    };

    Code.prototype.reRender = function() {
      var html;
      this.$code[0].innerHTML = "";
      this._firstRowShown = false;
      html = this._buildHtml(this._codeStack);
      return Rainbow.color(html, "css", (function(_this) {
        return function(highlighted_code) {
          return _this.$code.append(highlighted_code);
        };
      })(this));
    };

    Code.prototype.convert = function() {
      var newCodeStack;
      newCodeStack = [];
      _.each(this._codeStack, function(element) {
        var psudoClass, _i, _len, _ref;
        _ref = Code._psudoClasses;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          psudoClass = _ref[_i];
          if (element.name.indexOf("_" + psudoClass) !== -1) {
            element.name = element.name.replace("_" + psudoClass, ":" + psudoClass);
            break;
          }
        }
        return newCodeStack.push(element);
      });
      this._codeStack = newCodeStack;
      this.render(this._codeStack, this._codeStack.length, true, false);
      return message.setMessage("code", "File's names converted to psudo-classes", "production");
    };

    Code.prototype.clear = function() {
      this._codeStack = [];
      this.$code[0].innerHTML = "";
      return this._firstRowShown = false;
    };

    Code.prototype.highlightElement = function(icon) {
      return this.$code.find(".class").each((function(_this) {
        return function() {
          var $icon;
          $icon = $(this);
          if (icon.name === $icon.text().replace(".", "")) {
            $icon.scrollView({
              container: _this.$area,
              complete: function() {
                return $icon.effect("highlight");
              }
            });
          }
        };
      })(this));
    };

    Code.prototype.deteleIcon = function(icon) {
      this._codeStack = _.reject(this._codeStack, function(currentIcon) {
        return currentIcon.name === icon.name;
      });
      return this.reRender();
    };

    Code.prototype._buildHtml = function(elements) {
      var element, html, templ, _i, _len;
      if (!$.isArray(elements)) {
        message.setMessage("code", "elments to render must be an array", "debug");
      }
      templ = Handlebars.compile(Code._template[this.format].block);
      html = "";
      if (this._firstRowShown === false) {
        html += Handlebars.compile(Code._template[this.format].start)({
          fileName: this._fileName
        });
        this._firstRowShown = true;
      }
      for (_i = 0, _len = elements.length; _i < _len; _i++) {
        element = elements[_i];
        html += templ(element);
      }
      return html += Code._template[this.format].end;
    };

    return Code;

  })();

  Message = (function() {
    window.Message = Message;

    Message._production = "production";

    Message._debug = "debug";

    Message.prototype._modePermittedStatus = [Message._debug, Message._production];

    Message.prototype._messages = [];

    function Message(params) {
      if (!params) {
        return false;
      }
      this._$area = $(params.area);
      this._$title = $(params.title);
      if (_.contains(this._modePermittedStatus, params.mode)) {
        this._mode = params.mode;
      } else {
        this._mode = Message._production;
      }
    }

    Message.prototype.setMessage = function(sender, message, status) {
      var $message;
      if (!(sender && message)) {
        return false;
      }
      if (_.isUndefined(status)) {
        status = Message._production;
      }
      if (this._messages.length === 0) {
        this._$title.hide();
      }
      this._messages.push({
        sender: sender,
        message: message,
        status: status
      });
      if (status === Message._production || (status === Message._debug && this._mode === Message._debug)) {
        $message = $("<p class='message'>" + message + "</p>");
        if (this._$area.find("p").length > 0) {
          this._$area.find("p").first().before($message);
        } else {
          this._$area.append($message);
        }
        return $message.hide().fadeIn();
      }
    };

    Message.prototype.getMessage = function(mode) {
      var message, productionMessages, _i, _len, _ref, _results;
      if (!mode || mode === Message._debug) {
        return this._messages;
      } else {
        productionMessages = [];
        _ref = this._messages;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          message = _ref[_i];
          if (message === Message._production) {
            _results.push(productionMessages.push(message));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };

    return Message;

  })();

  Space = (function() {
    Space.prototype._spaceWidth = 0;

    Space.prototype._spaceHeight = 0;

    Space.prototype._emptySpaces = [];

    Space.prototype._biggestWidth = 0;

    Space.prototype._biggestHeight = 0;

    function Space(width, height) {
      if (!(width && height)) {
        return false;
      }
      this._spaceWidth = width;
      this._spaceHeight = height;
      this._emptySpaces.push({
        width: width,
        height: height,
        top: 0,
        left: 0
      });
    }

    Space.prototype.clear = function(setWidth, setHeight) {
      this._biggestWidth = 0;
      this._biggestHeight = 0;
      if (setWidth && setHeight) {
        this._spaceWidth = setWidth;
        this._spaceHeight = setHeight;
      }
      this._emptySpaces = [
        {
          width: this._spaceWidth,
          height: this._spaceHeight,
          top: 0,
          left: 0
        }
      ];
      return true;
    };

    Space.prototype.place = function(elementWidth, elementHeight) {
      var emptySpace, i, position, _i, _len, _ref;
      position = void 0;
      _ref = this._emptySpaces;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        emptySpace = _ref[i];
        if (elementHeight < emptySpace.height) {
          if (elementWidth > emptySpace.width) {
            continue;
          }
          position = {
            top: emptySpace.top,
            left: emptySpace.left
          };
          this._emptySpaces.splice(i, 0, {
            width: emptySpace.width - elementWidth,
            height: elementHeight,
            top: emptySpace.top,
            left: emptySpace.left + elementWidth
          });
          this._emptySpaces[i + 1] = {
            width: emptySpace.width,
            height: emptySpace.height - elementHeight,
            top: emptySpace.top + elementHeight,
            left: emptySpace.left
          };
          break;
        } else if (elementHeight === emptySpace.height) {
          if (elementWidth > emptySpace.width) {
            continue;
          }
          position = {
            top: emptySpace.top,
            left: emptySpace.left
          };
          this._emptySpaces[i] = {
            width: emptySpace.width - elementWidth,
            height: emptySpace.height,
            top: emptySpace.top,
            left: emptySpace.left + elementWidth
          };
          break;
        }
      }
      if (!position) {
        message.setMessage("Space", "Your image is too big for the actual canvas size. If you want to place that image you need to resize the cavans", "production");
        return false;
      }
      if (position.top + elementHeight > this._biggestHeight) {
        this._biggestHeight = position.top + elementHeight;
      }
      if (position.left + elementWidth > this._biggestWidth) {
        this._biggestWidth = position.left + elementWidth;
      }
      return position;
    };

    Space.prototype.fit = function() {
      var emptySpace, i, _i, _len, _ref;
      this._spaceWidth = this._biggestWidth;
      message.setMessage("Space", "New space width: " + this._spaceWidth, "debug");
      this._spaceHeight = this._biggestHeight;
      message.setMessage("Space", "New space height: " + this._spaceHeight, "debug");
      _ref = this._emptySpaces;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        emptySpace = _ref[i];
        if (emptySpace.left + emptySpace.width > this._spaceWidth) {
          this._emptySpaces[i].width = this._spaceWidth - emptySpace.left;
        }
        if (emptySpace.top + emptySpace.height > this._spaceHeight) {
          this._emptySpaces[i].height = this._spaceHeight - emptySpace.top;
        }
      }
      return this;
    };

    Space.prototype.getArea = function() {
      return {
        width: this._spaceWidth,
        height: this._spaceHeight
      };
    };

    Space.prototype.deleteElement = function(left, top, width, height) {
      return this._emptySpaces.unshift({
        width: width,
        height: height,
        top: top,
        left: left
      });
    };

    return Space;

  })();

}).call(this);

//# sourceMappingURL=app.js.map
