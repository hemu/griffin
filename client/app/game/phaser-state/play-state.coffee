mSession = require '../play/session'

class PlayState extends Phaser.State

  # note @game is passed in automatially here because of parent
  # Phaser.State
  constructor: ->
    super

  create: ->
    # SessionHost is the main class that holds all the
    # game logic and objects
    @shost = new mSession.SessionHost(@game)
    @shost.initialize(
      [
        {id: "1", name: "UnluckyAmbassador"},
        {id: "2", name: "VizualMenace"},
        {id: "3", name: "Gentlemen Killah"}
      ],
      @null)

  update: ->
    # XXX decouple this dt time from Phaser for server implementation
    dt = @game.time.physicsElapsed
    @shost.update(dt)

  render: ->
    @shost.render()

exports.PlayState = PlayState