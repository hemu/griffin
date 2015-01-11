'use strict'

console.log "game.coffee module"
require('angular')
require('angular-socket-io')
mGameFactory = require('./game-factory')

griffinAppGameModule = angular.module 'griffinApp.game', [
  'btford.socket-io',
]

.factory 'socket', (socketFactory) ->
  console.log "defining factory socket in griffinAppGameModule"
  return socketFactory()

.controller 'GameCtrl', (socket) ->
  socket.connect();
  console.log "GameCtrl triggered"
  console.log socket
  socket.emit('playerJoinMap', 'hey')
  console.log "socket emitted playerJoinMap"

.directive 'gameCanvasCont', ($injector) ->
  linkFn = (scope, ele, attrs) ->
    mGameFactory.createGame scope, scope.players, scope.mapId, ele, $injector
    
  return {
    scope:
      players: '='
      mapId: '='
    template: '<div id="gameCanvas"></div>'
    link: linkFn 
  }

module.exports = griffinAppGameModule