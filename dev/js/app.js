(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function() {
  var App;

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

}).call(this);

},{}]},{},[1])