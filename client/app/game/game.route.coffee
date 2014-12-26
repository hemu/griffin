angular.module 'griffinApp.game'
.config ($routeProvider) ->
  $routeProvider
  .when '/game',
    templateUrl: 'app/game/game.html'
    controller: 'GameCtrl'
    console.log "/ route triggered"