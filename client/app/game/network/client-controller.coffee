# postal is pub/sub library
postal = require('postal')
Channel = require('signal-message/signal').Channel
Signal = require('signal-message/signal').Signal
SignalKey = require('signal-message/signal').Key
mNetworkAssistant = require('network/network-assistant');

class ClientController

  constructor: ->
    @assistant = new mNetworkAssistant.NetworkAssistant(this)

  initialize: (socket) ->
    @assistant.initialize(socket)
    @initializeComm()

  initializeComm: ->
    @channel = postal.channel()
    @subSetup = @channel.subscribe Channel.SETUP, (data) =>
      if data.msg == Signal.IN_JOIN
        @assistant.start()

  registerStartGame: ->
    signal = {}
    signal[SignalKey] = Signal.START
    @channel.publish Channel.SETUP, signal
    

module.exports.ClientController = ClientController