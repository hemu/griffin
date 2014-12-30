mConfig = require './game-config'

# worth considering if we will get a win later by separating into 
# KeyboardInputs and MouseInputs. so same inputs module 
# would export inputs.KeyboardInput, inputs.MouseInput classes
class GameInput

  @shost = null

  @spaceIsDown = false

  @leftDragLast = null

  @issuerIsNotActive: () ->
    # XXX in future need to check if the player issuing this command
    # is the active player
    if @shost.active_player == null #|| @shost.active_player.id != @shost.sessionId
      return true
    if @shost.endingTurn
      return true
    return false

  @update: (dt) ->

    # ==========================================================================
    # Actions allowed for active player only
    if @issuerIsNotActive()
      return

    if (@shost.game.input.keyboard.isDown(Phaser.Keyboard.LEFT))
      @shost.playerMoveLeft(dt)
    else if (@shost.game.input.keyboard.isDown(Phaser.Keyboard.RIGHT))  
      @shost.playerMoveRight(dt)
    else if (@shost.game.input.keyboard.isDown(Phaser.Keyboard.UP))  
      @shost.playerAimUp(dt)
    else if (@shost.game.input.keyboard.isDown(Phaser.Keyboard.DOWN))  
      @shost.playerAimDown(dt)

    if @spaceIsDown
      @shost.playerChargeShot(dt)

  @setupInputs: () ->
    # Disable certain keys from propagating to browser
    @shost.game.input.keyboard.addKeyCapture([
    #  Phaser.Keyboard.UP,
      Phaser.Keyboard.DOWN,
      Phaser.Keyboard.LEFT,
      Phaser.Keyboard.RIGHT,
      Phaser.Keyboard.SPACEBAR
      ])

    @shost.game.input.onDown.add(@leftMouseDown, this)
    @shost.game.input.onUp.add(@leftMouseUp, this)
    @shost.game.input.addMoveCallback(@leftMouseMove, this)
    @shost.game.input.keyboard.addKey(Phaser.Keyboard.SPACEBAR).onDown.add(
      @spaceKeyDown, this);
    @shost.game.input.keyboard.addKey(Phaser.Keyboard.SPACEBAR).onUp.add(
      @spaceKeyUp, this)

  @leftMouseDown: () ->
    if mConfig.GameConstant.debug
      console.log 'clicked left mouse'
    # Anyone can move the camera, doesn't need to be active player, so don't
    # add issuerIsNotActive check here.
    # Note we're using screenspace x,y instead of world space
    @leftDragLast = [
      @shost.game.input.activePointer.x, 
      @shost.game.input.activePointer.y]

  @leftMouseMove: () ->
    if @leftDragLast == null
      return
    moveX = @shost.game.input.activePointer.x
    moveY = @shost.game.input.activePointer.y
    dX = moveX - @leftDragLast[0]
    dY = moveY - @leftDragLast[1]
    @shost.playerMoveCamera(dX, dY)
    @leftDragLast = [moveX, moveY]

  @leftMouseUp: () ->
    if mConfig.GameConstant.debug
      console.log 'released left mouse'
    #upX = @shost.game.input.activePointer.x
    #upY = @shost.game.input.activePointer.y
    #dX = upX - @leftDragStart[0]
    #dY = upY - @leftDragStart[1]
    @leftDragLast = null
    @shost.playerReleaseCamera()

  @testHealthPopups: () ->
    amt = Math.random() * 30 + 30
    amt = Math.floor(amt)
    ExplosionFactory.createRedHPTextBasic(
      @shost.game, 
      @shost.game.input.activePointer.worldX, 
      @shost.game.input.activePointer.worldY,
      amt)

  @spaceKeyDown: () ->
    if @issuerIsNotActive()
      return
    #console.log 'space key down'
    #@shost.playerFire()
    @spaceIsDown = true

  @spaceKeyUp: () ->
    if @issuerIsNotActive()
      return
    @spaceIsDown = false
    #console.log 'space key up'
    @shost.playerFire()

exports.GameInput = GameInput