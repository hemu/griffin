'use strict';

var Logger = function(msgTag) {
  this._enabled = true;
  this._msgTag = msgTag;
};

Logger.prototype.enable = function(isEnabled) {
  this._enabled = isEnabled;
};

Logger.prototype.log = function(msg) {
  console.log("["+this._msgTag+" LOG] " + msg);
}

Logger.prototype.err = function(msg) {
  console.log("["+this._msgTag+" ERR] " + msg);
}

module.exports.Logger = Logger