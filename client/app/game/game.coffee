'use strict'

require('angular')
io = require('socket.io-client')
mSessionFactory = require('session/session-factory')

griffinAppGameModule = angular.module 'griffinApp.game', []

.factory 'socket', ->
  return io
  
.controller 'GameCtrl', (socket) ->
  console.log "GameCtrl triggered"

.directive 'gameCanvasCont', ($injector, socket) ->
  linkFn = (scope, ele, attrs) ->
    mSessionFactory.create scope, socket
    
  return {
    scope:
      players: '='
      mapId: '='
    template: '<div id="gameCanvas"></div>'
    link: linkFn 
  }

module.exports = griffinAppGameModule