mStates = require('./phaser-state')

createGame = (scope, players, mapId, ele, injector) ->
  # height  = parseInt ele.css('height'), 10
  # width   = parseInt ele.css('width'), 10
  game = new Phaser.Game(800, 600, Phaser.CANVAS, "gameCanvas")
  # Cleanup
  scope.$on '$destroy', ->
    console.log "game destroyed."
    # socket.emit 'playerLeftMap', {
    #   playerId: g.sid
    #   mapId: g.mapId
    # }
    game.destroy()

  game.state.add 'Boot', new mStates.boot.BootState, false
  game.state.add 'Preloader', new mStates.preloader.PreloaderState, false
  game.state.add 'MainMenu', new mStates.menu.MainMenuState, false
  game.state.add 'Join', new mStates.join.JoinState, false
  game.state.add 'Play', new mStates.play.PlayState, false

  game.state.start 'Boot', true, false, null


module.exports.createGame = createGame