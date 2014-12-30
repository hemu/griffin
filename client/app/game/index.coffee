mGameFactory = require('./game-factory')

require('./game')
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