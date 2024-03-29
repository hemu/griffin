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
    @emitter.subscribeToInit( (initConfig) =>
        @registerPlayers(initConfig) #send player configs here
      )
    @emitter.subscribeToTurn( (turnConfig) =>
        @changeTurn(turnConfig)
      )

  initialize: (socket) ->
    @clientController.initialize(socket)
    # TODO: managing @phaserClient and states should prob be
    # done by some other helper objs
    # XXX: right now states just kick off other states
    @phaserClient = new Phaser.Game(1024, 640, Phaser.CANVAS, "phaserGameCanvas")
    @phaserClient.state.add 'Boot', new mState.boot.BootState, false
    @phaserClient.state.add 'Preloader', new mState.preloader.PreloaderState, false
    @phaserClient.state.add 'MainMenu', new mState.menu.MainMenuState, false
    joinState = new mState.join.JoinState
    joinState.controller = this
    @phaserClient.state.add 'Join', joinState, false
    @playState = new mState.play.PlayState
    @phaserClient.state.add 'Play', @playState, false
    @phaserClient.state.start 'Boot', true, false, null
  
  registerInJoin: ->
    @emitter.signalPlayerReady()

  registerPlayers: (initConfig) ->
    # player config
    # {
    #    init: 
    #      id0: 
    #        pos: [x0, y0]
    #      id1:
    #        pos: [x1, y1]
    #    myid: "Awkjhds72jds2sd"
    #    turn: "Awkjhds72jds2sd"
    # }

    # this calls the state's init method and passes initConfig and self
    # as params
    @phaserClient.state.start "Play", true, false, initConfig, this

  changeTurn: (turnConfig) ->
    console.log turnConfig['tid']
    playController = @playState.playController
    playController.changeTurn(turnConfig)


module.exports = SessionController