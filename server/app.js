/**
 * Main application file
 */

'use strict';

// Set default node environment to development
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

var express = require('express');
var mongoose = require('mongoose');
var config = require('./config/environment');
// Need this to require shared modules without having to
// specify .coffee extension
require('coffee-script/register');

// Connect to database
mongoose.connect(config.mongo.uri, config.mongo.options);

// Populate DB with sample data
if(config.seedDB) { require('./config/seed'); }

// Setup server
var app = express();
var server = require('http').createServer(app);
// on client side, socketio is actually handled by 
// angular-socket-io module which wraps functionality 
// in a socket service
// https://github.com/btford/angular-socket-io
var io = require('socket.io');
var sockets = io.listen(server);

// sockets.on('connection', function(socket){
//   console.log('************** a user connected ****************');
//   socket.on('playerJoinMap', function(msg){
//     console.log("player joined map");
//     console.log(msg);
//   })
// });

// var socketio = io(server, {
//   serveClient: (config.env === 'production') ? false : true,
//   path: '/socket.io-client'
// });

// require('./config/socketio')(socketio);
// require('./routes-sockets/io-route.js')(app, socketio);
require('./config/express')(app);
require('./routes')(app);

// Start server
server.listen(config.port, function () {
  console.log('Express server listening on %d, in %s mode', config.port, app.get('env'));
});

// shared module example
// var mathTest = require('shared-core/math-test');
// mathTest();

// console.log("******** postal test *********");
// var postal = require('postal');
// console.log("done importing postal")

// var channel = postal.channel();
// // subscribe to 'name.change' topics
// var subscription = channel.subscribe( "name.change", function ( data ) {
//     console.log("name change detected!");
//     console.log(data.name);
// } );
// // And someone publishes a name change:
// channel.publish( "name.change", { name : "Dr. Who" } );
// // To unsubscribe, you:
// subscription.unsubscribe();

// start game loop
var mGame = require('./game/game');
var game = new mGame.Game();
game.initialize(sockets);

// Expose app
exports = module.exports = app;