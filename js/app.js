(function() {
  var App, Canvas, Code, Message, Space;

  App = (function() {
    var clear, convert, deleteIcon, fileDrag, fit, parseFile;

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
      this._canvas.getArea().on({
        dragover: fileDrag,
        dragleave: fileDrag,
        drop: parseFile,
        click: function(e) {
          var icon, mousePosition, selectedIcon, _i, _len, _ref, _ref1, _ref2;
          e.stopPropagation();
          this._canvasIconTooltip.$tooltip.off(".deleteIcon");
          mousePosition = this._canvas.getMousePos(e);
          _ref = this._icons;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            icon = _ref[_i];
            if ((icon.left <= (_ref1 = mousePosition.x) && _ref1 <= icon.left + icon.width) && (icon.top <= (_ref2 = mousePosition.y) && _ref2 <= icon.top + icon.height)) {
              selectedIcon = icon;
              break;
            }
          }
          if (selectedIcon) {
            this._code.highlightElement(selectedIcon);
            this._canvasIconTooltip.$tooltip.removeClass("hidden").css({
              left: this._canvasIconTooltip.addToLeft + selectedIcon.left + selectedIcon.width / 2,
              top: this._canvasIconTooltip.addToTop + selectedIcon.top + selectedIcon.height,
              width: 150,
              marginLeft: -75
            });
            this._canvasIconTooltip.$tooltip.on("click.deleteIcon", this._canvasIconTooltip.buttons.deleteIcon, function() {
              return deleteIcon(selectedIcon);
            });
            return $("body").on("click.iconSelection", function() {
              this._canvasIconTooltip.$tooltip.off(".deleteIcon");
              this._canvasIconTooltip.$tooltip.addClass("hidden");
              return $(this).off(".iconSelection");
            });
          }
        }
      });
      $(document).on("rerender", function(e, ui) {
        var icon, newPosition, _i, _len, _ref;
        _ref = this._icons;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          icon = _ref[_i];
          newPosition = this._canvas.place(icon.width, icon.height);
          icon.left = newPosition.left;
          icon.top = newPosition.top;
          this._code.render(icon, this._icons.length, false, true);
        }
        this._canvas.reRender(this._icons);
        return this._reRenderCallback(e, ui);
      });
      $(document).ready(function() {
        $(this._buttons.fit).on("click", (function(_this) {
          return function() {
            return fit();
          };
        })(this));
        $(this._buttons.convert).on("click", (function(_this) {
          return function() {
            return convert();
          };
        })(this));
        $(this._buttons.clear).on("click", (function(_this) {
          return function() {
            return clear();
          };
        })(this));
        $(this._buttons.save).on("click", (function(_this) {
          return function() {
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
          };
        })(this));
        $(this._buttons.load).on("click", (function(_this) {
          return function() {
            return $(_this._buttons.loadInput).val("").trigger("click");
          };
        })(this));
        $(this._buttons.loadInput).on("change", function(e) {
          var file, reader;
          file = $(this)[0].files[0];
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
            clear();
            _results = [];
            for (_i = 0, _len = loadedIcons.length; _i < _len; _i++) {
              loadedIcon = loadedIcons[_i];
              icon = new Image();
              icon.setSrc(loadedIcon.src);
              icon.setName(loadedIcon.name);
              icon.setPosition(this._canvas.place(icon.width, icon.height));
              this._icons.push(icon);
              this._code.render(icon, loadedIcons.length, false);
              this._canvas.render(icon, loadedIcons.length);
              _results.push(this._iconOnloadCallback());
            }
            return _results;
          };
          return reader.readAsText(file);
        });
        return this._$downloadAnchor.on("click", function() {
          var canvasHtmlElement, codeFile, codeText;
          canvasHtmlElement = this._canvas.getArea()[0];
          canvasHtmlElement.toBlob(function(blob) {
            return saveAs(blob, "" + this._downloadFileName + ".png");
          });
          codeText = this._code.getCode().text();
          codeFile = new Blob([codeText], {
            type: "text/css;charset=utf-8;"
          });
          return saveAs(codeFile, this._downloadFileName + "." + this._code.getFormat());
        });
      });
    }

    fileDrag = function(e) {
      e.stopPropagation();
      e.preventDefault();
      return e.target.className = e.type === "dragover" ? "hover" : "";
    };

    parseFile = function(e) {
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
                icon.setPosition(this._canvas.place(icon.width, icon.height));
                this._icons.push(icon);
                this._code.render(icon, files.length, false);
                this._canvas.render(icon, files.length);
                return this._iconOnloadCallback();
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

    fit = function() {
      return this._canvas.fit(this._icons);
    };

    convert = function() {
      return this._code.convert();
    };

    clear = function() {
      this._icons = [];
      this._canvas.clear();
      this._code.clear();
      return message.setMessage("app", "Now your project is empty", "production");
    };

    deleteIcon = function(icon) {
      this._icons = _.reject(this._icons, function(currentIcon) {
        return currentIcon.name === icon.name;
      });
      this._canvas.deleteIcon(icon);
      this._code.deteleIcon(icon);
      return message.setMessage("app", "Icon " + icon.name + " deleted", "production");
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
    var $area, $background, addingArray, context, height, numElementsCounter, resizeCallback, space, stopCallback, width;

    $area = {};

    $background = {};

    resizeCallback = null;

    stopCallback = null;

    context = {};

    height = 0;

    width = 0;

    space = {};

    numElementsCounter = 1;

    addingArray = [];

    function Canvas(ctx) {
      if (!ctx) {
        return false;
      }
      $area = $(ctx.area);
      $background = $(ctx.background);
      resizeCallback = ctx.resizeCallback;
      stopCallback = ctx.stopCallback;
      context = $area[0].getContext("2d");
      height = $area.height();
      width = $area.width();
      space = new Space(width, height);
      $area.resizable({
        helper: "ui-resizable-helper",
        maxWidth: $area.parent().width() - parseInt($area.css("marginRight")) * 2,
        handles: "se",
        resize: function(e, ui) {
          return resizeCallback(e, ui);
        },
        stop: (function(_this) {
          return function(e, ui) {
            _this.setWidth(ui.size.width);
            _this.setHeight(ui.size.height);
            _this.clear();
            $(document).trigger("rerender", ui);
            return stopCallback(e, ui);
          };
        })(this)
      });
    }

    Canvas.prototype.getArea = function() {
      return $area;
    };

    Canvas.prototype.setHeight = function(newHeight) {
      if (newHeight) {
        height = newHeight;
        return $area.attr("height", height);
      }
    };

    Canvas.prototype.setWidth = function(newWidth) {
      if (newWidth) {
        width = newWidth;
        return $area.attr("width", width);
      }
    };

    Canvas.prototype.getHeight = function() {
      return height;
    };

    Canvas.prototype.getWidth = function() {
      return width;
    };

    Canvas.prototype.getContext = function() {
      return context;
    };

    Canvas.prototype.getMousePos = function(e) {
      var rect;
      rect = $area[0].getBoundingClientRect();
      return {
        x: e.clientX - rect.left,
        y: e.clientY - rect.top
      };
    };

    Canvas.prototype.place = function(width, height) {
      return space.place(width, height);
    };

    Canvas.prototype.clear = function() {
      addingArray = [];
      space.clear(width, height);
      return context.clearRect(0, 0, width, height);
    };

    Canvas.prototype.drawImage = function(IconsArray) {
      var icon, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = IconsArray.length; _i < _len; _i++) {
        icon = IconsArray[_i];
        _results.push(this.getContext().drawImage(icon, icon.left, icon.top));
      }
      return _results;
    };

    Canvas.prototype.render = function(Icon, numElements) {
      if (!Icon) {
        return false;
      }
      addingArray.push(Icon);
      if (numElementsCounter < numElements) {
        numElementsCounter++;
      } else {
        this.drawImage(addingArray);
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
      space.fit();
      newSpaceArea = space.getArea();
      oldWidth = width;
      oldHeight = height;
      this.setWidth(newSpaceArea.width);
      this.setHeight(newSpaceArea.height);
      $area.css({
        width: width,
        height: height
      });
      this.drawImage(Icons);
      newBackgroundWidth = $background.width() + width - oldWidth;
      newBackgroundHeight = $background.height() + height - oldHeight;
      $area.closest(".ui-wrapper").animate({
        width: width,
        height: height
      });
      $background.animate({
        width: newBackgroundWidth,
        height: newBackgroundHeight
      });
      return message.setMessage("Canvas", "Now your icons are perfectly fitted into the image", "production");
    };

    Canvas.prototype.deleteIcon = function(icon) {
      addingArray = _.reject(addingArray, function(currentIcon) {
        return currentIcon.name === icon.name;
      });
      space.deleteElement(icon.left, icon.top, icon.width, icon.height);
      return context.clearRect(icon.left, icon.top, icon.width, icon.height);
    };

    return Canvas;

  })();

  Code = (function() {
    var $area, $code, $formatSelector, addingArray, buildHtml, codeStack, data, fileName, filter, firstRowShown, format, formatArray, numElementsCounter, psudoClasses, template, _this;

    _this = {};

    $area = {};

    $code = {};

    filter = {};

    data = {};

    $formatSelector = {};

    formatArray = ["css", "less", "scss", "sass"];

    fileName = "";

    template = {
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

    format = {};

    firstRowShown = false;

    codeStack = [];

    psudoClasses = ["link", "visited", "hover", "active"];

    numElementsCounter = 1;

    addingArray = [];

    function Code(params) {
      if (!params) {
        return false;
      }
      _this = this;
      $area = $(params.area);
      $code = $(params.code);
      fileName = params.fileName;
      filter = params.filter;
      data = params.data;
      $formatSelector = $(params.format);
      if (_.contains(formatArray, $formatSelector.filter(filter).data(data))) {
        format = $formatSelector.filter(filter).data(data);
      } else {
        format = formatArray[0];
      }
      $formatSelector.on("formatCodeSelected", function() {
        format = $(this).find(filter).data(data);
        if (firstRowShown) {
          return _this.render(codeStack, void 0, true);
        }
      });
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
        addingArray.push(element);
        if (numElementsCounter < numElements) {
          numElementsCounter++;
        } else {
          $code[0].innerHTML = $code[0].innerHTML.substring(0, $code[0].innerHTML.length - 2);
          html = buildHtml(addingArray);
          codeStack = codeStack.concat(addingArray);
          numElementsCounter = 1;
          addingArray = [];
        }
      } else {
        $code[0].innerHTML = "";
        firstRowShown = false;
        html = buildHtml(codeStack);
      }
      return Rainbow.color(html, "css", function(highlighted_code) {
        return $code.append(highlighted_code);
      });
    };

    Code.prototype.reRender = function() {
      var html;
      $code[0].innerHTML = "";
      firstRowShown = false;
      html = buildHtml(codeStack);
      return Rainbow.color(html, "css", function(highlighted_code) {
        return $code.append(highlighted_code);
      });
    };

    Code.prototype.getArea = function() {
      return $area;
    };

    Code.prototype.getCode = function() {
      return $code;
    };

    Code.prototype.getFormat = function() {
      return format;
    };

    Code.prototype.convert = function() {
      var newCodeStack;
      newCodeStack = [];
      _.each(codeStack, function(element) {
        var psudoClass, _i, _len;
        for (_i = 0, _len = psudoClasses.length; _i < _len; _i++) {
          psudoClass = psudoClasses[_i];
          if (element.name.indexOf("_" + psudoClass) !== -1) {
            element.name = element.name.replace("_" + psudoClass, ":" + psudoClass);
            break;
          }
        }
        return newCodeStack.push(element);
      });
      codeStack = newCodeStack;
      this.render(codeStack, codeStack.length, true, false);
      return message.setMessage("code", "File's names converted to psudo-classes", "production");
    };

    Code.prototype.clear = function() {
      codeStack = [];
      $code[0].innerHTML = "";
      return firstRowShown = false;
    };

    Code.prototype.highlightElement = function(icon) {
      return $code.find(".class").each(function() {
        var $icon;
        $icon = $(this);
        if (icon.name === $icon.text().replace(".", "")) {
          $icon.scrollView({
            container: $area,
            complete: function() {
              return $icon.effect("highlight");
            }
          });
        }
      });
    };

    Code.prototype.deteleIcon = function(icon) {
      codeStack = _.reject(codeStack, function(currentIcon) {
        return currentIcon.name === icon.name;
      });
      return this.reRender();
    };

    buildHtml = function(elements) {
      var element, html, templ, _i, _len;
      if (!$.isArray(elements)) {
        message.setMessage("code", "elments to render must be an array", "debug");
      }
      templ = Handlebars.compile(template[format].block);
      html = "";
      if (firstRowShown === false) {
        html += Handlebars.compile(template[format].start)({
          fileName: fileName
        });
        firstRowShown = true;
      }
      for (_i = 0, _len = elements.length; _i < _len; _i++) {
        element = elements[_i];
        html += templ(element);
      }
      return html += template[format].end;
    };

    return Code;

  })();

  Message = (function() {
    var $area, $title, debug, messages, mode, modePermittedStatus, production;

    window.Message = Message;

    $area = {};

    $title = {};

    mode = "";

    production = "production";

    debug = "debug";

    modePermittedStatus = [debug, production];

    messages = [];

    function Message(params) {
      if (!params) {
        return false;
      }
      $area = $(params.area);
      $title = $(params.title);
      if (_.contains(modePermittedStatus, params.mode)) {
        mode = params.mode;
      } else {
        mode = production;
      }
    }

    Message.prototype.setMessage = function(sender, message, status) {
      var $message;
      if (!(sender && message)) {
        return false;
      }
      if (_.isUndefined(status)) {
        status = production;
      }
      if (messages.length === 0) {
        $title.hide();
      }
      messages.push({
        sender: sender,
        message: message,
        status: status
      });
      if (status === production || (status === debug && mode === debug)) {
        $message = $("<p class='message'>" + message + "</p>");
        if ($area.find("p").length > 0) {
          $area.find("p").first().before($message);
        } else {
          $area.append($message);
        }
        return $message.hide().fadeIn();
      }
    };

    Message.prototype.getMessage = function(mode) {
      var message, productionMessages, _i, _len, _results;
      if (!mode || mode === debug) {
        return messages;
      } else {
        productionMessages = [];
        _results = [];
        for (_i = 0, _len = messages.length; _i < _len; _i++) {
          message = messages[_i];
          if (message === production) {
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
    var biggestHeight, biggestWidth, emptySpaces, spaceHeight, spaceWidth;

    spaceWidth = 0;

    spaceHeight = 0;

    emptySpaces = [];

    biggestWidth = 0;

    biggestHeight = 0;

    function Space(width, height) {
      if (!(width && height)) {
        return false;
      }
      spaceWidth = width;
      spaceHeight = height;
      emptySpaces.push({
        width: width,
        height: height,
        top: 0,
        left: 0
      });
    }

    Space.prototype.clear = function(setWidth, setHeight) {
      biggestWidth = 0;
      biggestHeight = 0;
      if (setWidth && setHeight) {
        spaceWidth = setWidth;
        spaceHeight = setHeight;
      }
      emptySpaces = [
        {
          width: spaceWidth,
          height: spaceHeight,
          top: 0,
          left: 0
        }
      ];
      return true;
    };

    Space.prototype.place = function(elementWidth, elementHeight) {
      var emptySpace, i, position, _i, _len;
      position = void 0;
      for (i = _i = 0, _len = emptySpaces.length; _i < _len; i = ++_i) {
        emptySpace = emptySpaces[i];
        if (elementHeight < emptySpace.height) {
          if (elementWidth > emptySpace.width) {
            continue;
          }
          position = {
            top: emptySpace.top,
            left: emptySpace.left
          };
          emptySpaces.splice(i, 0, {
            width: emptySpace.width - elementWidth,
            height: elementHeight,
            top: emptySpace.top,
            left: emptySpace.left + elementWidth
          });
          emptySpaces[i + 1] = {
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
          emptySpaces[i] = {
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
      if (position.top + elementHeight > biggestHeight) {
        biggestHeight = position.top + elementHeight;
      }
      if (position.left + elementWidth > biggestWidth) {
        biggestWidth = position.left + elementWidth;
      }
      return position;
    };

    Space.prototype.fit = function() {
      var emptySpace, i, _i, _len;
      spaceWidth = biggestWidth;
      message.setMessage("Space", "New space width: " + spaceWidth, "debug");
      spaceHeight = biggestHeight;
      message.setMessage("Space", "New space height: " + spaceHeight, "debug");
      for (i = _i = 0, _len = emptySpaces.length; _i < _len; i = ++_i) {
        emptySpace = emptySpaces[i];
        if (emptySpace.left + emptySpace.width > spaceWidth) {
          emptySpaces[i].width = spaceWidth - emptySpace.left;
        }
        if (emptySpace.top + emptySpace.height > spaceHeight) {
          emptySpaces[i].height = spaceHeight - emptySpace.top;
        }
      }
      return this;
    };

    Space.prototype.getArea = function() {
      return {
        width: spaceWidth,
        height: spaceHeight
      };
    };

    Space.prototype.deleteElement = function(left, top, width, height) {
      return emptySpaces.unshift({
        width: width,
        height: height,
        top: top,
        left: left
      });
    };

    return Space;

  })();

}).call(this);
