'use strict';
// garageserver.io is a multiplayer framework that takes in
// client inputs, updates object states, and broadcasts new states.
// It handles client side prediction, interpolation, reconciliation.
var garageServer = require('../vendor/garageserver/garageserver.io');
//var gamePhysics = require('../../shared/core');
var mLogger = require('../logger');
var mNetworkMessage = require('../../shared-core/network-message/network-message')
var Event = mNetworkMessage.Event
var MessageKey = mNetworkMessage.MessageKey

var Game = function (socket) {
  this.serverLog = new mLogger.Logger('garage-server');
  this.gLog = new mLogger.Logger('game');
  this.socket = socket
  this.physicsInterval = 15;
  this.physicsDelta = this.physicsInterval / 1000;
  this.physicsIntervalId = 0;
};

Game.prototype.initialize = function(sockets) {
  var self = this;
  this.gameServer = garageServer.createGarageServer(sockets, 
    {
      logging: true,
      interpolation: false,
      clientSidePrediction: true,
      smoothingFactor: 0.3,
      interpolationDelay: 50,
      onPlayerConnect: function(socket) {
        self.registerClient(socket);
      },
      onPlayerDisconnect: function() {
        self.serverLog.log('player disconnected.');
      }
    });
};

Game.prototype.registerClient = function(socket) {
  this.gLog.log("new player registered");
  if(this.isFull()){
    this.gLog.log("all players have connected. starting game loop.");
    this.start();
  }
}

// XXX For now hardcoded to return true once
// there are 2 clients
Game.prototype.isFull = function() {
  var players = this.gameServer.getPlayers();
  return (players && players.length == 2);
}

Game.prototype.start = function() {
  var self = this;
  this.physicsIntervalId = setInterval(
                               function() { self.update(); }, 
                               this.physicsInterval
                           );
  this.gameServer.start();
  this.broadcastEvent(this.getEvent(Event.START_GAME));
  this.gLog.log("game started.");
};

Game.prototype.getEvent = function(evt) {
  var msg = {}
  msg[MessageKey.EVENT] = evt;
  return msg;
}

// should eventually be factored out into a separate
// assistant object
Game.prototype.broadcastEvent = function(data){
  this.gameServer.sendPlayersEvent(data);
}

// Update loop
// -----------
// Advance player and entity states based on any new inputs.
// Entities are any objects with state that will be simulated by server (e.g. projectiles).
// Players are special types of entities that can receive input from client.
Game.prototype.update = function() {
  // ---- update players ----
  // var players = this.gameServer.getPlayers(),
  //     entities = this.gameServer.getEntities(),
  //     self = this;

  // players.forEach(function (player) {
  //   var newState = gamePhysics.getNewPlayerState(
  //                         player.state,
  //                         player.inputs,
  //                         self.physicsDelta,
  //                         self.gameServer);
  //   self.gameServer.updatePlayerState(player.id, newState);
  // });

  // // ---- update Entities ----
  // for (var i = entities.length - 1; i >= 0; i--) {
  //   var entity = entities[i],
  //     newState = gamePhysics.getNewEntityState(entity.state, self.physicsDelta);

  //   self.gameServer.updateEntityState(entity.id, newState);
  //   // if (newState.x < -200 || newState.y < -200 || newState.x > 2000 || newState.y > 2000) {
  //   //   self.gameServer.removeEntity(entity.id);
  //   // } else {
  //   //   self.gameServer.updateEntityState(entity.id, newState);
  //   // }
  // }
};

exports.Game = Game;