module.exports = 
(function(app, io) {
  // var util = require('util');
  // var Player = require('./../models/Player');
  // var Map = require('./../models/Map');
  console.log("io-routes............");
  g = {
    io: undefined,
    players: [],
    maps: {}
  };

  function init(sio) {
    console.log("initing io");
    g.io = sio;
    bindSocketEvents();
    return g;
  }

  function bindSocketEvents() {
    console.log("bindSocketEvents");
    g.io.sockets.on('connection', function onConnection(socket) {
      console.log("New client connected to server: " + socket.id);
      socket.emit('connected', { id: socket.id });
      // var player = new Player({ id: socket.id });
      // g.players.push(player);
      socket.on('playerJoinMap', onPlayerJoinMap);
      // socket.on('updatePlayer', onUpdatePlayer);
      // socket.on('disconnect', onDisconnect);
      // socket.on('playerLeftMap', onPlayerLeftMap);
      // socket.on('shotbullet', onShotBullet);
      // socket.on('playerHit', onPlayerHit);
      // socket.on('setPlayerName', onSetPlayerName);
      // Get all the maps
      // socket.on('getMaps', onGetMaps);
    });
  }

  var onPlayerJoinMap = function(data) {
    console.log("new player joined map");
    console.log("******************************");
    console.log("******************************");
    console.log(data);
  }

  init(io);

});