class @GameUI
  @shost = null
  @ui_group = null        # phaser group to add all the sprites to

  # Bottom action bar, includes background and movement + shot firing
  @action_sprite = null
  @icon_move_sprite = null
  @icon_shot_sprite = null
  @move_bg_bar = null
  @shot_bg_bar = null
  @move_bar = null
  @shot_bar = null
  @crop_move = null
  @crop_shot = null
  @shot_max_width = null
  @move_max_width = null
  @shot_save = null
  # turn timer
  @turn_time_text = null
  
  # Creates and returns a sprite which will be added to the @ui_group
  # @img: name of image file to use for sprite
  # @screenFractionW: The FRACTION of total screen width image should take up
  #  scaleX and scaleY will be calculated based on this
  # @posX, posY: the position, in pixels, to place the sprite
  # @ancX, ancY: the anchor coordinates, 0-1
  # @ screenFractionPadX/Y: The FRACTION of total screen width image should be
  # padded, useful for fine alignment
  @setupSprite: (img, screenFractionW, posX, posY, 
    ancX, ancY,
    screenFractionPadX, screenFractionPadY) ->

    screenW = @shost.game.width
    screenH = @shost.game.height

    sprite = new Phaser.Sprite(
      @shost.game, 0, 0, img)
    sprite.fixedToCamera = true
    sprite.anchor = 
      x: ancX
      y: ancY
    desiredW = screenW * screenFractionW
    scaleFactor = desiredW/sprite.width
    sprite.scale.set( scaleFactor, scaleFactor)
    sprite.cameraOffset.set(
      posX + screenFractionPadX * screenW, 
      posY + screenFractionPadY * screenH)
    @ui_group.add(sprite)
    return sprite

  @initialize: (@shost) ->

    @ui_group = @shost.game.add.group()

    # add the action UI which the player uses to move and fire
    screenW = @shost.game.width
    screenH = @shost.game.height

    screenFractionW = 0.5
    @action_sprite = @setupSprite('actionui', screenFractionW, 
      screenW/2, screenH,
      0.5, 1,
      0, -0.02)
    screenFractionW = 0.03
    @icon_move_sprite = @setupSprite('icon_move', screenFractionW, 
      screenW/2 - @action_sprite.width/2, 
      @action_sprite.cameraOffset.y - @action_sprite.height,
      0.5, 0.5,
      0.03, 0.03
      )
    @icon_shot_sprite = @setupSprite('icon_shot', screenFractionW,
      screenW/2 - @action_sprite.width/2,
      @action_sprite.cameraOffset.y - @action_sprite.height/2,
      0.5, 0.5,
      0.03, 0.02)
    screenFractionW = 0.4
    @move_bg_bar = @setupSprite('bluebar', screenFractionW,
      screenW * (0.5 - screenFractionW/2), 
      screenH - @action_sprite.height,
      0.0, 0,
      0.01, -0.02 + 0.02)
    @move_bg_bar.alpha = 0.3
    @move_bar = @setupSprite('bluebar', screenFractionW,
      screenW * (0.5 - screenFractionW/2), 
      screenH - @action_sprite.height,
      0.0, 0,
      0.01, -0.02 + 0.02)
    @move_max_width = @move_bar.width / @move_bar.scale.x
    @crop_move = new Phaser.Rectangle(0, 0, 
      @move_max_width, 
      @move_bar.height / @move_bar.scale.y)
    @move_bar.crop(@crop_move)
    @move_bar.updateCrop()
    # For cropping we need to anchor the redbar at 0,0.  This makes setting its
    # X,Y a little trickier.  We set it to screenW / 2, then shift over by its
    # screenFractionW/2
    @shot_bg_bar = @setupSprite('redbar', screenFractionW,
      screenW * (0.5 - screenFractionW/2), 
      @action_sprite.cameraOffset.y - @action_sprite.height/2,
      0.0, 0,
      0.01, 0.0)
    @shot_bg_bar.alpha = 0.3
    @shot_bar = @setupSprite('redbar', screenFractionW,
      screenW * (0.5 - screenFractionW/2), 
      @action_sprite.cameraOffset.y - @action_sprite.height/2,
      0, 0,
      0.01, 0.0)
    @shot_max_width = @shot_bar.width / @shot_bar.scale.x
    @crop_shot = new Phaser.Rectangle(0, 0, 
      1, 
      @shot_bar.height / @shot_bar.scale.y)
    @shot_bar.crop(@crop_shot)
    @shot_bar.updateCrop()
    # saves the last shot charge for player
    screenFractionW = 0.02
    @shot_save = @setupSprite('icon_shot_save', screenFractionW,
      @shot_bar.cameraOffset.x,
      @shot_bar.cameraOffset.y,
      0.5, 0,
      0.0, -0.015)

    @turn_time_text = new Phaser.Text(@shost.game, 0, 0, '')
    @turn_time_text.fixedToCamera = true
    @turn_time_text.cameraOffset.set(16, 40)
    @ui_group.add(@turn_time_text)

  @bringToTop: () ->
    @shost.game.world.bringToTop(@ui_group)

  @updateMoveBar: (fraction) ->
    newWidth = @move_max_width * fraction
    newWidth = GameMath.clamp(newWidth, 1, @move_max_width)
    @crop_move.width = newWidth
    @move_bar.updateCrop()

  @updateShotBar: (fraction) ->
    newWidth = @shot_max_width * fraction
    newWidth = GameMath.clamp(newWidth, 1, @shot_max_width)
    @crop_shot.width = newWidth
    @shot_bar.updateCrop()

  @refreshShotSave: (fraction) ->
    @shot_save.cameraOffset.x = @shot_bar.cameraOffset.x + @shot_max_width * @shot_bar.scale.x * fraction

  @updateTurnTime: (tremaining) ->
    # if turn time is not below show time, hide the time display
    if tremaining > GameConstants.turnShowTime
      @turn_time_text.visible = false
    # if turn time is in show time, show the time
    else if tremaining > GameConstants.turnWarnTime
      @turn_time_text.visible = true
      @turn_time_text.setText(tremaining.toString())
      @turn_time_text.setStyle({fill: '#333333'})
    # if turn time is in warn time, show time in red
    else if tremaining > 0
      @turn_time_text.visible = true
      @turn_time_text.setText(tremaining.toString())
      @turn_time_text.setStyle({fill: '#ff0044'})
    # if turn time is negative or 0, hide it
    else
      @turn_time_text.visible = false

