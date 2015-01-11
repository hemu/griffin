'use strict'

console.log "game-route.coffee"
require('./game')
.config ($routeProvider) ->
  $routeProvider
  .when '/game',
    templateUrl: 'app/game/game.html'
    controller: 'GameCtrl'