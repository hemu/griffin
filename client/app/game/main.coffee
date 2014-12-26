window.createGame = (scope, players, mapId, ele, injector) ->
  # height  = parseInt ele.css('height'), 10
  # width   = parseInt ele.css('width'), 10
  height  = 480
  width   = 640
  game = new Phaser.Game(width, height, Phaser.AUTO, 'gameCanvas')

  # Cleanup
  scope.$on '$destroy', ->
    console.log "game destroyed."
    # socket.emit 'playerLeftMap', {
    #   playerId: g.sid
    #   mapId: g.mapId
    # }
    game.destroy()