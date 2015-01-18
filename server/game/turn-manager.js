'use strict';

var mDelay = require('./delay');
var GameConst = require('../../shared-core/game-constant');

var Timer = function() {
  this.timeRemain = 0;
  this.callback = null;
  this.active = false;
}

Timer.prototype.set = function(val) {
  this.timeRemain = val;
  this.active = true;
}

Timer.prototype.update = function(dt) {
  if(this.active){
    this.timeRemain -= dt;
    if(this.timeRemain <= 0){
      this.active = false;
    }
  }
  return this.active;
};

var TurnManager = function(game) {
  this.game = game;
  this.playerDelay = new mDelay.Delay();
  this.activePlayer = null;
  this.timer = new Timer(this);
};

TurnManager.prototype.initialize = function(ids) {
  this.playerDelay.initialize(ids);
}

TurnManager.prototype.startTurn = function(){
  this.updateActivePlayer();
  this.timer.set(GameConst.TURN_LENGTH);
}

TurnManager.prototype.update = function(dt) {
  var done = this.timer.update(dt);
  if(done){
    this.endTurn();
  }
}

TurnManager.prototype.endTurn = function() {
  this.playerDelay.addDelay(this.activePlayer, 100);
  this.game.registerTurnEnd();
}

TurnManager.prototype.updateActivePlayer = function() {
  this.activePlayer = this.playerDelay.getMinDelayId();
}

TurnManager.prototype.getActivePlayer = function() {
  return this.activePlayer;
}


module.exports.TurnManager = TurnManager