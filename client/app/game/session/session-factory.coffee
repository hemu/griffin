mSessionController = require('session/session-controller')

create = (scope, socket) ->
  sessionController = new mSessionController(socket)
  scope.$on '$destroy', ->
    console.log "game scope destroyed."
    # XXX TODO: need to properly destroy phaser game XXX
    #mSessionController.destroy()
    # socket.emit 'playerLeftMap', {
    #   playerId: g.sid
    #   mapId: g.mapId
    # }

module.exports.create = create