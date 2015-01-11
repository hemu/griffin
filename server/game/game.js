'use strict';
// garageserver.io is a multiplayer framework that takes in
// client inputs, updates object states, and broadcasts new states.
// It handles client side prediction, interpolation, reconciliation.
var garageServer = require('../vendor/garageserver/garageserver.io');
//var gamePhysics = require('../../shared/core');

function Game(socket) {
  console.log("initializing game with garageserver");
  this.physicsInterval = 15;
  this.physicsDelta = this.physicsInterval / 1000;
  this.physicsIntervalId = 0;
  var self = this;
  this.gameServer = garageServer.createGarageServer(socket, 
    {
      logging: false,
      interpolation: false,
      clientSidePrediction: true,
      smoothingFactor: 0.3,
      interpolationDelay: 50,
      onPlayerConnect: self.onPlayerConnect,
      onPlayerDisconnect: self.onPlayerDisconnect
    });
}

Game.prototype.onPlayerConnect = function() {
  console.log("player connected");
}

Game.prototype.onPlayerDisconnect = function() {
  console.log("player disconnected");
}

Game.prototype.start = function() {
  console.log("started game serverrrrrrrrr");
  var self = this;
  this.physicsIntervalId = setInterval(
                               function() { self.update(); }, 
                               this.physicsInterval
                           );
  this.gameServer.start();
};

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