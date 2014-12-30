'use strict'

require('angular')

console.log require('angular-socket-io')
griffinAppGameModule = angular.module 'griffinApp.game', []
.controller 'GameCtrl', ->
  console.log "game hello."
# .controller 'GameCtrl', ($scope, socket) ->
#   $scope.message = 'Hello'
#   # announce player joining map
#   console.log(socket)
#   socket.socket.emit('playerJoinMap', {socket: socket})

module.exports = griffinAppGameModule