mConfig = require 'world/game-config'
State = require 'controller/state'

# worth considering if we will get a win later by separating into 
# KeyboardInputs and MouseInputs. so same inputs module 
# would export inputs.KeyboardInput, inputs.MouseInput classes
class GameInput
  @controller = null
  @spaceIsDown = false
  @leftDragLast = null

  @issuerIsNotActive: () ->
    # XXX in future need to check if the player issuing this command
    # is the active player
    # if @controller.active_player == null #|| @controller.active_player.id != @controller.sessionId
    #   return true
    # if @controller.endingTurn
    return @controller.getState() == State.INPUT

  @update: (dt) ->

    # ==========================================================================
    # Actions allowed for active player only
    if @issuerIsNotActive()
      return

    if (@controller.game.input.keyboard.isDown(Phaser.Keyboard.LEFT))
      @controller.playerMoveLeft(dt)
    else if (@controller.game.input.keyboard.isDown(Phaser.Keyboard.RIGHT))  
      @controller.playerMoveRight(dt)
    else if (@controller.game.input.keyboard.isDown(Phaser.Keyboard.UP))  
      @controller.playerAimUp(dt)
    else if (@controller.game.input.keyboard.isDown(Phaser.Keyboard.DOWN))  
      @controller.playerAimDown(dt)

    if @spaceIsDown
      @controller.playerChargeShot(dt)

  @setupInputs: () ->
    console.log "setupInputs GameInput"
    # Disable certain keys from propagating to browser
    @controller.game.input.keyboard.addKeyCapture([
    #  Phaser.Keyboard.UP,
      Phaser.Keyboard.DOWN,
      Phaser.Keyboard.LEFT,
      Phaser.Keyboard.RIGHT,
      Phaser.Keyboard.SPACEBAR
      ])

    @controller.game.input.onDown.add(@leftMouseDown, this)
    @controller.game.input.onUp.add(@leftMouseUp, this)
    @controller.game.input.addMoveCallback(@leftMouseMove, this)
    @controller.game.input.keyboard.addKey(Phaser.Keyboard.SPACEBAR).onDown.add(
      @spaceKeyDown, this);
    @controller.game.input.keyboard.addKey(Phaser.Keyboard.SPACEBAR).onUp.add(
      @spaceKeyUp, this)

  @leftMouseDown: () ->
    if mConfig.GameConstant.debug
      console.log 'clicked left mouse'
    # Anyone can move the camera, doesn't need to be active player, so don't
    # add issuerIsNotActive check here.
    # Note we're using screenspace x,y instead of world space
    @leftDragLast = [
      @controller.game.input.activePointer.x, 
      @controller.game.input.activePointer.y]

  @leftMouseMove: () ->
    if @leftDragLast == null
      return
    moveX = @controller.game.input.activePointer.x
    moveY = @controller.game.input.activePointer.y
    dX = moveX - @leftDragLast[0]
    dY = moveY - @leftDragLast[1]
    @controller.playerMoveCamera(dX, dY)
    @leftDragLast = [moveX, moveY]

  @leftMouseUp: () ->
    if mConfig.GameConstant.debug
      console.log 'released left mouse'
    #upX = @controller.game.input.activePointer.x
    #upY = @controller.game.input.activePointer.y
    #dX = upX - @leftDragStart[0]
    #dY = upY - @leftDragStart[1]
    @leftDragLast = null
    @controller.playerReleaseCamera()

  @testHealthPopups: () ->
    amt = Math.random() * 30 + 30
    amt = Math.floor(amt)
    ExplosionFactory.createRedHPTextBasic(
      @controller.game, 
      @controller.game.input.activePointer.worldX, 
      @controller.game.input.activePointer.worldY,
      amt)

  @spaceKeyDown: () ->
    if @issuerIsNotActive()
      return
    #console.log 'space key down'
    #@controller.playerFire()
    @spaceIsDown = true

  @spaceKeyUp: () ->
    if @issuerIsNotActive()
      return
    @spaceIsDown = false
    #console.log 'space key up'
    @controller.playerFire()

exports.GameInput = GameInput