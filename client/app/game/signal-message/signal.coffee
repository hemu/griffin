# postal is pub/sub library
postal = require('postal')

# channels through which signals can be sent
Channel =
  INIT: 'game.init'
  TURN_SETUP: 'turn.setup'

# Signals available per channel
# by convention, name is <Channel>Signal
InitSignal =
  # server signals this when all players joined, start
  SETUP: 'st'
  # player signals this when ready to join, ready to connect
  JOIN: 'ij'

SetupSignal =
  PLAYER_SETUP: 'pt'

Key = 
  TYPE: 'sig'
  DATA: 'data'

# class to facilitate local signaling
class Signaler

  constructor: ->
    @channel = postal.channel()

  # --- signal --------------------------------
  signalInit: (initConfig) ->
    data = {}
    data[Key.TYPE] = InitSignal.SETUP
    data[Key.DATA] = initConfig
    @channel.publish Channel.INIT, data

  signalPlayerReady: ->
    data = {}
    data[Key.TYPE] = InitSignal.JOIN
    @channel.publish Channel.INIT, data

  signalTurn: (turnConfig) ->
    data = {}
    data[Key.TYPE] = SetupSignal.PLAYER_SETUP
    data[Key.DATA] = turnConfig
    @channel.publish Channel.TURN_SETUP, data
  # ---------------------------------------------

  # --- subscriptions ---------------------------
  subscribeToInit: (callback) ->
    @channel.subscribe Channel.INIT, (data) =>
      if data[Key.TYPE] == InitSignal.SETUP
        callback(data[Key.DATA])

  subscribeToPlayerReady: (callback) ->
    @channel.subscribe Channel.INIT, (data) =>
      if data[Key.TYPE] == InitSignal.JOIN
        callback()

  # sends id of player turn
  subscribeToTurn: (callback) ->
    @channel.subscribe Channel.TURN_SETUP, (data) =>
      if data[Key.TYPE] == SetupSignal.PLAYER_SETUP
        callback(data[Key.DATA])
  #-----------------------------------------------


module.exports.Signal = InitSignal
module.exports.Signal = SetupSignal
module.exports.Signaler = Signaler