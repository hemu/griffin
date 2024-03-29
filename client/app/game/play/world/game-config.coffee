class GameConstant

  # set debug to draw collision previz, etc
  @debug = false

  # time in seconds after player turn-ending move to end turn
  @endTurnWaitTime = 1.6
  @turnTime = 600
  @turnShowTime = 600
  @turnWarnTime = 600

  # The base health for which healthbar scale.x = 1
  @healthBase = 100

  @playerScale = 0.4

  # When walking, how big a jump in Y in world terrain is too high
  # before you can't walk.
  @maxWalkableY = 5

  # How many neighboring tiles, to the left and right, to use when
  # determining if the bottom of the player is standing on solid ground.
  # Note that left and right movement should also share this same width
  # for spacing collision columns when detecting if player can move left 
  # or right 
  @playerBaseCollisionTiles = 12
  # How many neighboring tiles, to the left and right, to use the vertical
  # column of tiles to check whether right or left side is colliding with world
  @playerSideCollisionStartY = 12
  # How long the vertical column of lateral collision checking tiles is
  @playerSideCollisionTiles = 20

  # the Y position past which things die, such as players or bullets falling
  # to their death
  #@gameYBound = 2000

  # travel distance before bullet can collide with self
  @bulletSelfHitDist = 20

  @gravity = 8000

  # ============================================================================
  # CAMERA
  # ============================================================================
  # XXX Currently Phaser doesn't work well with zooming camera or world, so
  # keep this 1 until one day in future Phaser fixes camera following while
  # scale is not 1
  @cameraScale = 1
  # How many sections to split screen up to form deadzone with padding of
  # 1/cameraDeadzoneTiles to the left and right
  @cameraDeadzoneY = 100
  # For special Jolt camera effect, what's maximum jolt pixels
  @cameraJoltPx = 20
  # How fast the camera moves when player drags
  @cameraDragRate = 1.5
  # The background image is larger than the camera zone for the parallax effect
  @backgroundImageScale = 1.5
  @midgroundImageScale = 1.9

exports.GameConstant = GameConstant