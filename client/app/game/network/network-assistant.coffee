# facilitates communication with server
# abstracts away client-server messaging

# fix needing to use ../../
mGarageServer = require('../../vendor/garageserver.io')
mNetworkMessage = require('network-message/network-message')
MessageKey = mNetworkMessage.MessageKey
Event = mNetworkMessage.Event

class NetworkAssistant

  constructor: (@client) ->

  initialize: (socket) ->
    @garageServer = mGarageServer.GarageServerIO(socket)

  start: ->
    # TODO: url should be a config parameter, not hardcoded
    @garageServer.initializeGarageServer('http://localhost:9000', 
      logging: true,
      onReady: @onReady,
      onUpdatePlayerPrediction: @onUpdatePlayerPrediction,
      onEvent: @onEvent,
      onInterpolation: @onInterpolation
    )

  onReady: =>
    console.log "garage server ready"

  onEvent: (data) =>
    console.log "-- received event --"
    console.log data
    # XXX TODO better check to make sure key exists
    if data[MessageKey.EVENT] == Event.START_GAME
      @client.registerStartGame()

  onUpdatePlayerPrediction: =>
    console.log "player update from garage server"
    
  onInterpolation: =>
    console.log "garageserver interpolation"


module.exports.NetworkAssistant = NetworkAssistant