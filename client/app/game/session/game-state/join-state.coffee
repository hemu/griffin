# wait for all players to join game
# wait for game start signal from server
# then advance to play state

class JoinState extends Phaser.State

  create: ->
    @controller.registerInJoin()

exports.JoinState = JoinState