mUtil = require 'util/game-util'

class ReticuleCore
  constructor: (@player) ->
    @aim_dirty = false
    @facingLeft = true
    @maxAim = 90
    @minAim = 0

  initialize: (@oX, @oY, @aimDist, @aimAngle, @scale = 1) ->
    @aimX = @aimDist * Math.cos(@aimAngle)
    @aimY = -@aimDist * Math.sin(@aimAngle)

  setMaxAim: (@maxAim) ->
    if @aimAngle > @maxAim
      @aimAngle = @maxAim
      @aim_dirty = true

  setMinAim: (@minAim) ->
    if @aimAngle < @minAim
      @aimAngle = @minAim
      @aim_dirty = true

  getOrigin: () ->
    return [@oX, @oY]

  changeDirection: (faceLeft) ->
    if faceLeft
      @facingLeft = true
    else
      @facingLeft = false

  addAimAngle: (angle) ->
    @aimAngle += angle
    @aimAngle = mUtil.GameMath.clamp(@aimAngle, @minAim, @maxAim)
    @aim_dirty = true

  update: (playerX, playerY) ->
    # only update the reticule XY if aim changed so don't incur sin and cos
    if @aim_dirty
      @aimX = @aimDist * Math.cos(mUtil.GameMath.deg2rad(@aimAngle))
      @aimY = -@aimDist * Math.sin(mUtil.GameMath.deg2rad(@aimAngle))

class ReticuleClient extends ReticuleCore

  constructor: (@player) ->
    super @player
    @sprite = null

  # @ox, @oy are the origin of the reticule, and conceptually should be 
  # centered on the "cannon" of the player sprite.  This is the "mouth of
  # the muzzle" of the player's cannon.
  #
  # @aimDist is how far away from the origin the reticule is drawn
  # @aimAngle is the current angle of aim of the reticule.  0 is level with
  # the player, and 90 is directly above player's head
  initialize: (@oX, @oY, @aimDist, @aimAngle, @scale = 1) ->
    super @oX, @oY, @aimDist, @aimAngle, @scale
    @sprite = new Phaser.Sprite(@player.shost.game, 0, 0, 'reticule')
    @sprite.anchor =
      x: 0.5
      y: 0.5
    @sprite.scale.x = @scale
    @sprite.scale.y = @scale
    @player.shost.playgroup.add(@sprite)

  changeDirection: (faceLeft) ->
    super faceLeft
    if faceLeft
      @sprite.scale.x = @scale
    else
      @sprite.scale.x = -@scale

  update: (playerX, playerY) ->
    super playerX, playerY

    dirSign = 1
    if @facingLeft
      dirSign = -1
    @sprite.x = playerX + (@oX + @aimX) * dirSign
    @sprite.y = playerY + @oY + @aimY
    @sprite.angle = -@aimAngle * dirSign

  kill: () ->
    @sprite.destroy()

exports.ReticuleCore = ReticuleCore
exports.ReticuleClient = ReticuleClient