mSignaler = require('signal-message/signal')
mNetworkAssistant = require('network/network-assistant');

class ClientController

  constructor: ->
    @assistant = new mNetworkAssistant.NetworkAssistant(this)

  initialize: (socket) ->
    @assistant.initialize(socket)
    @initializeComm()

  initializeComm: ->
    @emitter = new mSignaler.Signaler
    @emitter.subscribeToPlayerReady( =>
      @assistant.start()
      )

  registerInitGame: (initConfig) ->
    @emitter.signalInit(initConfig)

module.exports.ClientController = ClientController