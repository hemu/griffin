'use strict';
// garageserver.io is a multiplayer framework that takes in
// client inputs, updates object states, and broadcasts new states.
// It handles client side prediction, interpolation, reconciliation.
var garageServer = require('../vendor/garageserver/garageserver.io');
//var gamePhysics = require('../../shared/core');
var mLogger = require('../logger');
var mNetworkMessage = require('../../shared-core/network-message/network-message');
var mTurnManager = require('./turn-manager');
var Event = mNetworkMessage.Event;
var MessageKey = mNetworkMessage.MessageKey;

var Game = function (socket) {
  this.serverLog = new mLogger.Logger('garage-server');
  this.gLog = new mLogger.Logger('game');
  this.socket = socket;
  this.physicsInterval = 15;
  this.physicsDelta = this.physicsInterval / 1000;
  this.physicsIntervalId = 0;
};

Game.prototype.initialize = function(sockets) {
  var self = this;
  this.currentTurnId = null;
  this.turnManager = new mTurnManager.TurnManager(this);
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

  this.dt = 0.015;
  this.accumulator = 0.0;
  
};

Game.prototype.registerClient = function(socket) {
  this.gLog.log("new player registered");
  if(this.isFull()){
    this.gLog.log("all players have connected. starting game loop.");
    this.start();
  }
};

Game.prototype.registerTurnEnd = function() {
  console.log("registered end");
  this.turnManager.startTurn();
  var activePlayerId = this.turnManager.getActivePlayer();
  var msg = {};
  msg[MessageKey.TURN] = activePlayerId;
  this.broadcastEvent(Event.CHANGE_TURN, msg);
}

// XXX For now hardcoded to return true once
//     there are 2 clients XXXXXXX
Game.prototype.isFull = function(){
  var players = this.gameServer.getPlayers();
  var curPlayer;

  return (players && players.length === 2);
};

Game.prototype.start = function(){
  var self = this;

  // initialize update loop time tracking
  var date = new Date()
  this.curTime = date.getTime()
  this.lastTime = this.curTime

  this.physicsIntervalId = setInterval(
                               function() { self.update(); }, 
                               this.physicsInterval
                           );
  this.gameServer.start();
  var players = this.gameServer.getPlayers();
  this.currentTurnId = players[0].id;
  this.gLog.log("game started.");
  // broadcast initialize message with data about
  // each player (positions, avatar, etc) + starting turn
  var msg = {};
  msg[MessageKey.INIT] = {};
  var playerIds = [];
  var curPlayer;
  var spawnPos = [[800,1413], [1160,1413], [400,1413]];
  for(var i=0, len=players.length; i<len; i++){
    curPlayer = players[i];
    // TODO just use fake x and y loc for now
    // eventually need to read in map spawn locations
    msg[MessageKey.INIT][curPlayer.id] = {pos: spawnPos[i]}
    playerIds.push(curPlayer.id);
  }
  msg[MessageKey.TURN] = this.currentTurnId;
  this.turnManager.initialize(playerIds);
  /*
  msg = {
    MessageKey.POS: {
      id0: [x, y]
      id1: [x, y]
    }
    MessageKey.TURN: id0
  }
  */
  this.broadcastEvent(Event.INIT_GAME, msg);
  this.turnManager.startTurn();
  /* sample players 
  [ { id: 'hhLBEGTQa69MBtNRAAAA',
      state: {},
      inputs: [],
      stateHistory: [] },
    { id: 'ihhkEA-yX5boeXziAAAB',
      state: {},
      inputs: [],
      stateHistory: [] } ]
  */
};

Game.prototype.getEvent = function(evtType, data){
  var evt = {}
  evt[MessageKey.EVENT] = evtType;
  evt[MessageKey.DATA] = data
  return evt;
};

// should eventually be factored out into a separate
// assistant object
Game.prototype.broadcastEvent = function(evtType, data){
  var newEvent = this.getEvent(evtType, data); 
  console.log("-- event broadcast --");
  console.log(newEvent);
  this.gameServer.sendPlayersEvent(newEvent);
};

// Update loop
// -----------
// Advance player and entity states based on any new inputs.
// Entities are any objects with state that will be simulated by server (e.g. projectiles).
// Players are special types of entities that can receive input from client.
Game.prototype.update = function(){
  var date = new Date();
  this.lastTime = this.curTime;
  this.curTime = date.getTime();

  var frameTime = (this.curTime - this.lastTime) / 1000.0
  this.accumulator += frameTime;

  //console.log('update');
  //console.log(frameTime);

  while(this.accumulator >= this.dt) {
    this.accumulator -= this.dt;
    this.turnManager.update(this.dt);
  }

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