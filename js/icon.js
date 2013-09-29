"use strict"

/* -------------
  Image extends Image Object 
  ---------------- */

var iconNameRegEx = new RegExp("(\w+)([^.]\w+)?$");

Image.prototype.delete = function () {};

Image.prototype.getPosition = function () {};

Image.prototype.setPosition = function (params) {
  if (params) {
    this.top = params.top; 
    this.left = params.left;
    return this;
  }
};

Image.prototype.setName = function (name) {
  if (name) {
    name = _.escape(name)
    this.name = name.replace(iconNameRegEx, "");
    return this;
  } 
};

Image.prototype.getName = function () {
  if(this.name) {
    return this.name;
  } else {
    return false;
  }
};

Image.prototype.validate = function () {};

Image.prototype.setSrc = function (src) {
  if (src) {
    this.src = src;
    return this;
  } 
};
/* End Get Code */