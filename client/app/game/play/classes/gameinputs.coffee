class @GameInputs

  @shost = null

  @spaceIsDown = false

  @issuerIsNotActive: () ->
    # XXX in future need to check if the player issuing this command
    # is the active player
    if @shost.active_player == null #|| @shost.active_player.id != @shost.sessionid
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
      Phaser.Keyboard.UP,
      Phaser.Keyboard.DOWN,
      Phaser.Keyboard.LEFT,
      Phaser.Keyboard.RIGHT,
      Phaser.Keyboard.SPACEBAR])

    #@shost.game.input.onDown.add(@leftMouseDown, this)
    #@shost.game.input.onUp.add(@leftMouseUp, this)
    #@shost.game.input.addMoveCallback(@leftMouseMove, this)
    @shost.game.input.keyboard.addKey(Phaser.Keyboard.SPACEBAR).onDown.add(
      @spaceKeyDown, this);
    @shost.game.input.keyboard.addKey(Phaser.Keyboard.SPACEBAR).onUp.add(
      @spaceKeyUp, this)

  """
  leftMouseDown: () ->
    console.log 'clicked left mouse'
    if @active_player == null || !@active_player.can_fire
      return
    # Note we're using screenspace x,y instead of world space
    @leftDragStart = [@game.input.activePointer.x, @game.input.activePointer.y]

  leftMouseMove: () ->
    if @leftDragStart == null || @active_player == null || !@active_player.can_fire
      return
    moveX = @game.input.activePointer.x
    dX = moveX - @leftDragStart[0]
    console.log dX

  leftMouseUp: () ->
    console.log 'released left mouse'
    if @active_player == null || !@active_player.can_fire
      return
    console.log @active_player
    upX = @game.input.activePointer.x
    dX = upX - @leftDragStart[0]
    console.log dX
    @leftDragStart = null
    """
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

