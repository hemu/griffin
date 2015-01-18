# facilitates communication with server
# abstracts away client-server messaging

# TODO fix needing to use ../../
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

  onEvent: (msg) =>
    console.log "-- received event --"
    console.log msg
    # XXX TODO better check to make sure key exists
    if msg[MessageKey.EVENT] == Event.INIT_GAME
      initConfig = 
        'init': msg[MessageKey.DATA][MessageKey.INIT]
        'turn': msg[MessageKey.DATA][MessageKey.TURN]
        'myid': @garageServer.getId()
      @client.registerInitGame(initConfig);

  onUpdatePlayerPrediction: =>
    console.log "player update from garage server"
    
  onInterpolation: =>
    console.log "garageserver interpolation"


module.exports.NetworkAssistant = NetworkAssistant