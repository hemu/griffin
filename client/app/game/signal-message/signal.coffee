# postal is pub/sub library
postal = require('postal')

Channel =
  SETUP: 'game.setup'

Signal =
  START: 'st'
  IN_JOIN: 'ij'

SignalKey = 'msg'

# class to facilitate local signaling
class Signaler

  constructor: ->
    @channel = postal.channel()

  signalStart: ->
    data = {}
    data[SignalKey] = Signal.START
    @channel.publish Channel.SETUP, data

  signalPlayerReady: ->
    data = {}
    data[SignalKey] = Signal.IN_JOIN
    @channel.publish Channel.SETUP, data

  subscribeToStart: (callback) ->
    @channel.subscribe Channel.SETUP, (data) =>
      callback(data)


module.exports.Signal = Signal
module.exports.Signaler = Signaler