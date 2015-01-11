# wait for all players to join game
# wait for game start signal from server
# then advance to play state

mGarageServer = require('../../vendor/garageserver.io')

class JoinState extends Phaser.State

  constructor: ->

  create: ->
    console.log "connecting to garage server"
    # mGarageServer.GarageServerIO.initializeGarageServer('http://localhost:9000', 
    #   logging: true,
    #   onReady: @update,
    #   onUpdatePlayerPrediction: @update
    #   onInterpolation: @update
    # )
    @startPlay()

  garageUpdate: ->
    console.log "player update from garage server"
    
  update: ->

  startPlay: ->
    playerConfigs = [
      {id: "1", name: "UnluckyAmbassador"},
      {id: "2", name: "VizualMenace"},
      {id: "3", name: "Gentlemen Killah"}
    ]
    @game.state.start "Play", true, false, playerConfigs


exports.JoinState = JoinState