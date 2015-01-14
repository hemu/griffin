'use strict'

require('angular')
griffinAppGameModule = angular.module 'griffinApp.game', []
.controller 'GameCtrl', ($scope, socket) ->
  $scope.message = 'Hello'
  # announce player joining map
  console.log(socket)
  socket.socket.emit('playerJoinMap', {socket: socket})