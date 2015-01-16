
# Channel = require('signal-message/signal').Channel
Signal = require('signal-message/signal').Signal
# SignalKey = require('signal-message/signal').Key
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
    @emitter.subscribeToStart( (data) =>
      if data.msg == Signal.IN_JOIN
        @assistant.start()
    )

  registerStartGame: ->
    @emitter.signalStart()

module.exports.ClientController = ClientController