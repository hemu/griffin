'use strict';

var INITIAL_DELAY = 0;

var Delay = function() {
  this.delays = {};
  this.delayIds = [];
};

Delay.prototype.initialize = function(ids) {
  this.delayIds = ids;
  for(var i=0, len=ids.length; i<len; i++){
    this.delays[ids[i]] = INITIAL_DELAY;
  }
}

Delay.prototype.addDelay = function(id, delayAmt) {
  this.delays[id] += delayAmt;
}

Delay.prototype.getMinDelayId = function() {
  var minId = this.delayIds[0];
  var minDelay = this.delays[minId];
  var curDelay = 0, curId = 0;
 
  for(var i=1, len=this.delayIds.length; i<len; i++){
    curId = this.delayIds[i];
    curDelay = this.delays[curId];
    if(curDelay < minDelay){
      curDelay = minDelay;
      minId = curId;
    }
  }
  return minId;
}


module.exports.Delay = Delay
