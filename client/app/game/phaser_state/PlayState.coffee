class @PlayState extends Phaser.State
	
	# note @game is passed in automatially here because of parent
	# Phaser.State
  constructor: ->
    super

  create: ->

    # SessionHost is the main class that holds all the
    # game logic and objects
    @shost = new SessionHost(@game)
    @shost.initialize(["1","2","3"],@null)

  update: ->

    # XXX decouple this dt time from Phaser for server implementation
    dt = @game.time.physicsElapsed

    @shost.update(dt)

  render: ->
    @shost.render()
