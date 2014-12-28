class @Bullet

  constructor: (@shost) ->

    @player = null  # player whom bullet belongs to

    @sprite = null

    # World collision detection and crater creation
    # These are in pixels, so for collisions against world need to convert
    # to tiles by dividing by world.tileSize
    @collisionRadiusPx = 20
    @craterRadiusPx = 50
    # Damage and explosion damage.  If a direct hit is achieved, the hit player
    # gets directHitDamage applied, but is ignored in the explosion damage.
    # All others hit by indirect explosionRadius will incur linearly decreasing
    # explosionMaxDamage based on percentage distance from explosion center
    @directHitDamage = 33
    # note that explosion radius is based on center of bullet to center of
    # player, so need to add at least player sprite width/2 to account for
    # that extra distance
    @explosionRadius = 70
    @explosionMaxDamage = 30
    @explosionMinDamage = 10

    @entity = null

    @distance_traveled_sq = 0  # save distance traveled as square to avoid sqrt
    @canHitFirer = false

  initialize: (@player, x, y, velocity, angle, @fx, @fy, @scale=1, rot=0) ->
    @sprite = new Phaser.Sprite(@shost.game, x, y, 'bullet')
    @sprite.angle = rot
    @sprite.scale.x = @scale
    @sprite.scale.y = @scale
    @sprite.anchor =
      x: 0.5
      y: 0.5
    @shost.playgroup.add(@sprite)

    @entity = new Entity(@shost)
    @entity.initialize(x, y, @collisionRadiusPx*2*@scale, @collisionRadiusPx*2*@scale, 0, 0)
    @shost.p2world.addBody(@entity.p2body)
    @entity.p2body.velocity[0] = velocity * Math.cos(GameMath.deg2rad(angle))
    @entity.p2body.velocity[1] = -velocity * Math.sin(GameMath.deg2rad(angle))
    @entity.setForce(fx, fy)

    if GameConstants.debug
      @entity.initPreviz(@shost.game)

  update: (world) ->

    old_pos = [@entity.x, @entity.y]
    @entity.update()
    new_pos = [@entity.x, @entity.y]
    tx = new_pos[0] - old_pos[0]
    ty = new_pos[1] - old_pos[1]
    @distance_traveled_sq += tx*tx + ty*ty
    if !@canHitFirer
      selfHitDist = GameConstants.bulletSelfHitDist
      if @distance_traveled_sq > selfHitDist * selfHitDist
        @canHitFirer = true

    # update the sprite to the ground truth simulated position
    @sprite.x = @entity.x
    @sprite.y = @entity.y

    doKillBullet = false
    spawnExplosion = false
    explosionIgnorePlayer = null
    damage = 0

    # ========================================
    # Player collisions
    for player in @shost.players
      if @entity.collidesWithEntity(player.entity)
        # if hit firer and not yet past self damage distance traveled, continue
        if player == @player && !@canHitFirer
          continue
        @drawExplosion(@entity.x, @entity.y, false)
        player.addHealth(-@directHitDamage)
        spawnExplosion = true
        doKillBullet = true
        explosionIgnorePlayer = player
        # also add a crater centered around bullet
        tileX = GameMath.clamp(world.xTileForWorld(@entity.x), 0, world.width-1)
        tileY = GameMath.clamp(world.yTileForWorld(@entity.y), 0, world.height-1)
        world.createCrater(tileX, tileY, @craterRadiusPx / world.tileSize)
        @shost.gcamera.jolt()
        break

    # ========================================
    # World collisions
    if !doKillBullet && @entity.collidesWithWorld(world)
      # create a crater in world from the center of the bullet
      if GameConstants.debug
        console.log 'Hit Ground'
      @drawExplosion(@entity.x, @entity.y, true)
      tileX = GameMath.clamp(world.xTileForWorld(@entity.x), 0, world.width-1)
      tileY = GameMath.clamp(world.yTileForWorld(@entity.y), 0, world.height-1)
      world.createCrater(tileX, tileY, @craterRadiusPx / world.tileSize)
      doKillBullet = true
      spawnExplosion = true
      @shost.gcamera.jolt()

    # ========================================
    # Spawn explosion, if necessary, which damages players linearly from
    # its epicenter up to @explosionRadius
    if spawnExplosion
      spawnPos = [@entity.x, @entity.y]
      explosionRadiusSq = @explosionRadius * @explosionRadius
      for player in @shost.players
        if player==explosionIgnorePlayer
          continue
        playerPos = [player.getX(), player.getY()]
        dx = playerPos[0] - spawnPos[0]
        dy = playerPos[1] - spawnPos[1]
        distFromExplosionSq = dx*dx + dy*dy
        damageDiff = @explosionMaxDamage - @explosionMinDamage
        dmgFactor = 1.0 - distFromExplosionSq / explosionRadiusSq
        damage = damageDiff * dmgFactor + @explosionMinDamage
        if dmgFactor > 0
          player.addHealth(-damage)

    # If bullet fell too far down, kill it
    if !doKillBullet 
      if @entity.y > @shost.world.gameYBound
        doKillBullet = true
      else if @entity.x < @shost.world.gameXBoundL || @entity.x > @shost.world.gameXBoundR
        doKillBullet = true

    if doKillBullet
      if GameConstants.debug
        console.log 'bullet died'
      @shost.removeBullet(this)
      @kill()
      @player.endTurn()

  kill: () ->
    @sprite.destroy(true)
    @sprite = null
    @entity.kill()
    @entity = null

  drawExplosion: (x, y, hitGround) ->
    ExplosionFactory.createExplosionBasic(@shost.game, x, y)
    if hitGround
      ExplosionFactory.createPebbleBasic(@shost.game, x, y)
    else
      ExplosionFactory.createFlareBasic(@shost.game, x, y)




