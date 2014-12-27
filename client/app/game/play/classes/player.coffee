class @Player

  # XXX This is hacky for testing. Player shouldn't be controlling
  #     their own movement

  constructor: (@shost) ->
    @sprite = null
    @maxhealth = 100
    @curhealth = 100
    @healthsprite = null
    @healthbarsprite = null
    @aimspeed = 70
    @speed = 70
    @max_movement = 200
    @cur_movement = 0
    @facingLeft = true
    @id = null
    @active = false

    # firing and charging shot
    @reticule = null
    @can_fire = false
    @shot_charge_rate = 500
    @shot_charge = 0
    @max_shot_charge = 1500
    @last_charge = 0        # used to show last shot strength indicator

    @entity = null
    
  initialize: (@shost, @id, x, y, @scale=1, rot=0) ->
    @sprite = new PlayerSprite(@shost.game, x, y, 'player')
    @sprite.angle = rot
    @sprite.scale.x = @scale
    @sprite.scale.y = @scale
    @shost.playgroup.add(@sprite)

    # Create physics entity
    @entity = new Entity(@shost)
    # XXX previz is for showing collision logic to ground
    #previzW = 2*GameConstants.playerBaseCollisionTiles * @shost.world.tileSize
    #previzH = (GameConstants.playerSideCollisionStartY) * @shost.world.tileSize
    #@entity.initialize(x, y, previzW, previzH, 0, -previzH/2)
    @entity.initialize(x,y,70*@scale,100*@scale,0,-50*@scale)
    @shost.p2world.addBody(@entity.p2body)

    # Create reticule for aiming
    @reticule = new Reticule(this)
    # XXX should resolve these from the mount type's cannon location, which
    # should be a % of the sprite's width and height
    cannonXOff = 50*@scale
    cannonYOff = -40*@scale
    @reticule.initialize(cannonXOff, cannonYOff, 40, 0, 1)
    @reticule.setMaxAim(70)
    @reticule.setMinAim(10)

    if GameConstants.debug
      @entity.initPreviz(@shost.game)

  initHealth: (maxhealth) ->
    hscalex = maxhealth/GameConstants.healthBase
    @maxhealth = maxhealth
    @curhealth = maxhealth
    @healthbarsprite = new Phaser.Sprite(@shost.game, 0, 0, 'healthbar')
    @healthbarsprite.angle = 0
    @healthbarsprite.scale.x = hscalex
    @healthbarsprite.scale.y = 0.5
    @healthbarsprite.anchor =
      x: 0.0
      y: 0.5
    @healthbarsprite.x = -@healthbarsprite.width/2
    @healthbarsprite.y = 4
    @healthsprite = new Phaser.Sprite(@shost.game, 0, 0, 'health')
    @healthsprite.angle = 0
    @healthsprite.scale.x = hscalex
    @healthsprite.scale.y = 0.5
    @healthsprite.anchor =
      x: 0.0
      y: 0.5
    @healthsprite.x = -@healthsprite.width/2
    @healthsprite.y = 4
    @sprite.addChild(@healthbarsprite)
    @sprite.addChild(@healthsprite)

  addHealth: (health) ->
    @curhealth += health
    @curhealth = GameMath.clamp(@curhealth, 0, @maxhealth)
    @healthsprite.scale.x = @curhealth / GameConstants.healthBase

    if @curhealth <= 0
      @die()

  die: () ->
    if GameConstants.debug
        console.log 'player died'
    @sprite.destroy(true)
    @sprite = null
    @entity.kill()
    @entity = null
    @reticule.kill()
    @reticule = null
    @healthbarsprite.destroy(true)
    @healthbarsprite = null
    @healthsprite.destroy(true)
    @healthsprite = null
    if @active
      # if player is active player, endTurn will remove the player from game
      @endTurn(true)
    else
      # otherwise manually remove player from game right now
      @shost.removePlayer(this)

  makeFall: () ->
    @entity.p2body.force[1] = 2000

  clampToGround: (world) ->
    @entity.p2body.force[1] = 0
    @entity.p2body.velocity[1] = 0
    tileX = world.xTileForWorld(@getX())
    tileY = world.yTileForWorld(@getY())
    highestNonFreeTileY = world.highestNonFreeYTile(tileX, tileY)
    # if height is walkable, clamp it
    if highestNonFreeTileY > tileY - GameConstants.maxWalkableY
      @entity.p2body.position[1] = world.yWorldForTile(highestNonFreeTileY+1)
    
  checkWorldCollision: (world) ->

    # For the bottom 5 world tiles, check rgba
    # starting from center, 1 left, 1 right, 2 left, 2 right
    # if any are on solid ground, don't make fall and clamp to that one
    shouldFall = true
    checkNeighborTiles = [0]
    for i in [1 .. GameConstants.playerBaseCollisionTiles]
      checkNeighborTiles.push(-i)
      checkNeighborTiles.push(i)
    for i in checkNeighborTiles
      tile_rgba = world.getRgbaForWorldXY(@getX(), @getY())
      if world.isGround(tile_rgba)
        @clampToGround(world)
        shouldFall = false
        break
    if shouldFall
      @makeFall()

  # HACKY, use enums for direction
  changeDirection: (faceLeft) ->
    if faceLeft
      @sprite.scale.x = @scale
      @facingLeft = true
      @healthsprite.anchor.x = 0
      @healthsprite.x = -@healthbarsprite.width/2
    else
      @sprite.scale.x = -@scale
      @facingLeft = false
      @healthsprite.anchor.x = 1
      @healthsprite.x = @healthbarsprite.width/2
    @reticule.changeDirection(faceLeft)

  initTurn: ->
    if !@active
      return
    @cur_movement = 0
    @can_fire = true
    @shot_charge = 0

  endTurn: (died=false)->
    if !@active
      return
    @active = false
    @shost.tryEndPlayerTurn(died)
    @can_fire = false

  aimUp: (dt) ->
    aimChange = @aimspeed * dt
    @reticule.addAimAngle(aimChange)

  aimDown: (dt) ->
    aimChange = @aimspeed * dt
    @reticule.addAimAngle(-aimChange)

  chargeShot: (dt) ->
    @last_charge = @shot_charge
    addCharge = @shot_charge_rate * dt
    @shot_charge += addCharge
    @shot_charge = GameMath.clamp(@shot_charge, 1, @max_shot_charge)

  fire: () ->
    if !@can_fire
      return
    #console.log 'FIRE AWAY!'

    bullet = new Bullet(@shost)
    rorg = @reticule.getOrigin()

    dirSign = 1
    angle = @reticule.aimAngle
    if @facingLeft
      dirSign = -1
      angle = 180 - @reticule.aimAngle

    # XXX affected by wind, etc
    fx = 0
    fy = 9000 # bullet gravity
    bullet.collisionRadiusPx = 20
    bullet.explosionRadiusPx = 60
    vel = @shot_charge
    bullet.initialize(this, @getX() + dirSign *rorg[0], @getY() + rorg[1], vel, angle, fx, fy, 0.4, 0)
    
    @shost.bullets.push(bullet)
    @shost.gcamera.follow(bullet.sprite)

    @can_fire = false
    @last_charge = @shot_charge
    @shot_charge = 0

  moveLeft: (dt, world) ->
    if !@can_fire
      return
    @move(dt, world, true)

  moveRight: (dt, world) ->
    if !@can_fire
      return
    @move(dt, world, false)

  move: (dt, world, isLeft=false) ->
    if isLeft
      if not @facingLeft
        @changeDirection(true)
    else
      if @facingLeft
        @changeDirection(false)

    dirSign = 1
    if isLeft
      dirSign = -1

    # First check that the player still has remaning "movement points"
    # in his turn.  If not, don't allow moving.
    allowable_dist = @max_movement - @cur_movement
    if allowable_dist <= 0
      return

    # If this move will exhaust remaining "movement points", cap it to remaining
    # movement
    try_dist = @speed * dt
    if try_dist > allowable_dist
      try_dist = allowable_dist

    # =======================================================
    # First try our side checks.
    # 1. The flank collision check position is baseCollisionTiles + 1
    #    For example, if base collision width is 3 tiles to the right from 
    #    center, then at the 4th tile form the "collision column"
    # 2. Use a "collision column" at the flank collision position, starting
    #    from maxWalkableY up, check playerSideCollisionTiles num tiles
    #
    # The below diagram illustrates.
    #   'c' -> bottol collision center
    #   '-' -> baseCollisionTile
    #   '|' -> sideCollisionTile
    #   'G' -> Ground 
    #
    #         |       |
    #         |       |    GGGG
    #         |       |   GGGGGG
    #          ---c---    GGGGGGG
    #      GGGGGGGGGGGGGGGGGGGGG
    tileX = world.xTileForWorld(@getX())
    tileY = world.yTileForWorld(@getY())
    latTileX = tileX + (GameConstants.playerBaseCollisionTiles + 1) * dirSign
    latTileY = tileY - GameConstants.playerSideCollisionStartY
    tile_rgba = world.getRgbaForTileXY(latTileX, latTileY)
    if world.isGround(tile_rgba)
      return

    # =======================================================
    # Now see if the new position is walkable
    # 1. Check where the movement would take us if performed.
    # 2. If the terrain is air, let us walk
    # 3. If the terrain is ground, check if it is walkable by seeing if the
    #    top Y tile is within maxWalkableY
    # 4. If the terrain is not walkable, find the nearest X tile that is
    #    is walkable within maxWalkableY and clamp the X position there
    # 5. Find actual traversed distance by subtracting dist - actual walked
    #    which might have been clamped
    try_pos = @getX() + try_dist * dirSign
    tile_rgba = world.getRgbaForWorldXY(try_pos, @getY())

    # If new location is walkable, now need to check that there's no 
    # "floating walls" above it that would block lateral traversal
    if world.isAir(tile_rgba)
      actual_dist = try_dist
    else
      tileX = world.xTileForWorld(try_pos)
      tileY = world.yTileForWorld(@getY())
      highestNonFreeTileY = world.highestNonFreeYTile(tileX, tileY)
      # if height is walkable
      if highestNonFreeTileY > tileY - GameConstants.maxWalkableY
        actual_dist = try_dist
      else
        actual_dist = 0

    @cur_movement += actual_dist
    # XXX implement this:
    #@cur_movement += actual_walked_dist
    @setX(@getX() + actual_dist * dirSign)

  setX: (newX) ->
    @entity.setX(newX)
    @sprite.x = newX

  getX: ->
    return @entity.x

  setY: (newY) ->
    @entity.setY(newY)
    @sprite.y = newY

  getY: ->
    return @entity.y

  update: (world) ->

    @entity.update()

    @checkWorldCollision(world)

    # update the sprite to the ground truth simulated position
    @sprite.x = @entity.x
    @sprite.y = @entity.y

    if @getY() > @shost.world.gameYBound
      @die()
      return

    @reticule.update(@sprite.x, @sprite.y)

  hideUI: () ->
    @reticule.sprite.visible = false

  showUI: () ->
    @reticule.sprite.visible = true

class @PlayerSprite extends Phaser.Sprite
  
  constructor: ->
    super
    @anchor =
      x: 0.5
      y: 1
    # @scale.x = 0.24
    # @scale.y = 0.27