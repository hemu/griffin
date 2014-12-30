states = require('./phaser-state')

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

  game.state.add 'Boot', new states.boot.BootState, false
  game.state.add 'Preloader', new states.preloader.PreloaderState, false
  game.state.add 'MainMenu', new states.menu.MainMenuState, false
  game.state.add 'Play', new states.play.PlayState, false
  game.state.start 'Boot', true, false, null

  console.log game


module.exports.createGame = createGame