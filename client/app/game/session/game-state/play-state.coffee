mPlayController = require 'controller/play-controller'

class PlayState extends Phaser.State

  # note @game is passed in automatially here because of 
  # parent Phaser.State
  constructor: ->
    @curTime = null
    @lastTime = null
    @dt = 0.015         # runs physics at 66.6 fps
    @accumulator = 0.0
    super

  create: ->
    date = new Date()
    @curTime = date.getTime()
    @lastTime = @curTime

  # this gets called when game.state.start is called
  init: (playerConfigs, sessionController) ->
    @playController = new mPlayController.PlayController(@game, sessionController)
    @playController.initialize playerConfigs

  update: ->
    date = new Date()
    @lastTime = @curTime
    @curTime = date.getTime()

    frameTime = (@curTime - @lastTime) / 1000.0
    @accumulator += frameTime

    while @accumulator >= @dt
      @accumulator -= @dt
      @playController.update(@dt)

  render: ->
    @playController.render()
    @playController.game.debug.text(@playController.game.time.fps || '--', 2, 14, "#00ff00")

exports.PlayState = PlayState