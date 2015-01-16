# Channel = require('signal-message/signal').Channel
Signal = require('signal-message/signal').Signal
# SignalKey = require('signal-message/signal').Key
mSignaler = require('signal-message/signal')
mState = require('session/game-state')
mPlayController = require('controller/play-controller')
mClientController = require('network/client-controller')

class SessionController

  constructor: (socket) ->
    @clientController = new mClientController.ClientController()
    @initializeComm()
    @initialize(socket)

  initializeComm: ->
    @emitter = new mSignaler.Signaler
    @emitter.subscribeToStart( (data) =>
      if data.msg == Signal.START
        @registerPlayers({}) #send player configs here
    )

  initialize: (socket) ->
    @clientController.initialize(socket)
    # TODO: managing @phaserClient and states should prob be
    # done by some controller (maybe this one)
    # XXX: right now states just kick off other states
    @phaserClient = new Phaser.Game(800, 600, Phaser.CANVAS, "phaserGameCanvas")
    @phaserClient.state.add 'Boot', new mState.boot.BootState, false
    @phaserClient.state.add 'Preloader', new mState.preloader.PreloaderState, false
    @phaserClient.state.add 'MainMenu', new mState.menu.MainMenuState, false
    joinState = new mState.join.JoinState
    joinState.controller = this
    @phaserClient.state.add 'Join', joinState, false
    @phaserClient.state.add 'Play', new mState.play.PlayState, false
    @phaserClient.state.start 'Boot', true, false, null
  
  registerInJoin: ->
    @emitter.signalPlayerReady()

  registerPlayers: (playerConfigs) ->
    playerConfigs = [
      {id: "1", name: "UnluckyAmbassador"},
      {id: "2", name: "VizualMenace"},
      {id: "3", name: "Gentlemen Killah"}
    ]
    @phaserClient.state.start "Play", true, false, playerConfigs, this


module.exports = SessionController