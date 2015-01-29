mConfig = require 'world/game-config'
mUtil = require 'util/game-util'
mEffects = require 'world/game-effects'
mEntity = require 'entity/entity'

class Bullet

  constructor: (@shost) ->

    @player = null  # player whom bullet belongs to

    @sprite = null

    @scale = 1
    @rot = 0

    # Store the last position of the bullet so that when colliding at high 
    # speeds with terrain, for example, can check the last non-colliding
    # position of bullet to avoid getting stuck inside terrain.
    @lastPos = [0,0]

    # The bullet stats come from BulletSpecFactory, and are not populated
    # in the constructor
    @collisionRadiusPx = 20
    @craterRadiusPx = 50
    @directHitDamage = 33
    @explosionRadius = 70
    @explosionMaxDamage = 30
    @explosionMinDamage = 10
    @isTeleport = false

    # Draw members for Phaser
    @explosionGfxScale = 1
    @particleStart = null
    @particleAttach = null
    # need to manually kill attached emitters when die
    @attachedEmitters = []
    @particleEnd = null
    @teleportEnd = null

    @entity = null

    @distance_traveled = 0
    @canHitFirer = false

  initialize: (@player, x, y, velocity, angle, @fx, @fy, spec) ->

    @scale = spec.bullet_scale
    @collisionRadiusPx = spec.collisionRadiusPx

    @entity = new mEntity.Entity(@shost)
    @entity.initialize(x, y, @collisionRadiusPx*2*@scale, @collisionRadiusPx*2*@scale, 0, 0)
    @shost.p2world.addBody(@entity.p2body)
    @entity.p2body.velocity[0] = velocity * Math.cos(mUtil.GameMath.deg2rad(angle))
    @entity.p2body.velocity[1] = -velocity * Math.sin(mUtil.GameMath.deg2rad(angle))
    @entity.setForce(fx, fy)

    @initFromSpec(spec)

    if mConfig.GameConstant.debug
      @entity.initPreviz(@shost.game)

    if @particleStart != null
      @particleStart(@shost.game, x, y)

    if @particleAttach != null
      @attachedEmitters = @particleAttach(@shost.game, x, y)

  initFromSpec: (spec) ->

    @sprite = new Phaser.Sprite(@shost.game, 0, 0, spec.bullet_image)
    @sprite.anchor =
      x: 0.5
      y: 0.5
    @sprite.scale.x = @scale
    @sprite.scale.y = @scale
    @shost.playgroup.add(@sprite)

    @collisionRadiusPx = spec.collisionRadiusPx
    @craterRadiusPx = spec.craterRadiusPx
    @directHitDamage = spec.directHitDamage
    @explosionRadius = spec.explosionRadius
    @explosionMaxDamage = spec.explosionMaxDamage
    @explosionMinDamage = spec.explosionMinDamage
    @explosionGfxScale = spec.explosionGfxScale
    @particleStart = spec.particleStart
    @particleAttach = spec.particleAttach
    @particleEnd = spec.particleEnd
    # teleportation
    @isTeleport = spec.isTeleport
    @teleportEnd = spec.teleportEnd
    if @isTeleport
      @sprite.blendMode = Phaser.blendModes.ADD

  update: (world) ->

    @lastPos = [@entity.x, @entity.y]
    @entity.update()
    new_pos = [@entity.x, @entity.y]
    tx = new_pos[0] - @lastPos[0]
    ty = new_pos[1] - @lastPos[1]
    traveled = Math.sqrt(tx*tx + ty*ty)
    @distance_traveled += traveled
    if !@canHitFirer
      if @distance_traveled > mConfig.GameConstant.bulletSelfHitDist
        @canHitFirer = true

    # update the sprite to the ground truth simulated position
    @sprite.x = @entity.x
    @sprite.y = @entity.y
    # Update any attached emitters
    for emitter in @attachedEmitters
      emitter.x = @entity.x
      emitter.y = @entity.y

    # update the rotation of the bullet
    angle = Math.acos(ty / traveled)
    dirX = 1
    if (tx > 0)
      dirX = -1    
    @sprite.rotation = dirX*angle + mUtil.GameMath.PI

    doKillBullet = false
    spawnExplosion = false
    explosionIgnorePlayer = null
    doTeleport = false
    damage = 0

    # ========================================
    # Player collisions
    for player in @shost.players
      if @isTeleport
        continue
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
        tileX = mUtil.GameMath.clamp(world.xTileForWorld(@lastPos[0]), 0, world.width-1)
        tileY = mUtil.GameMath.clamp(world.yTileForWorld(@lastPos[1]), 0, world.height-1)
        world.createCrater(tileX, tileY, @craterRadiusPx / world.tileSize)
        @shost.gcamera.jolt()
        break

    # ========================================
    # World collisions
    if !doKillBullet && @entity.collidesWithWorld(world)
      # create a crater in world from the center of the bullet
      if mConfig.GameConstant.debug
        console.log 'Hit Ground'

      @drawExplosion(@lastPos[0], @lastPos[1], true)
      tileX = mUtil.GameMath.clamp(world.xTileForWorld(@lastPos[0]), 0, world.width-1)
      tileY = mUtil.GameMath.clamp(world.yTileForWorld(@lastPos[1]), 0, world.height-1)
      world.createCrater(tileX, tileY, @craterRadiusPx / world.tileSize)
      doKillBullet = true
      spawnExplosion = true
      if @isTeleport
        doTeleport = true
      else
        @shost.gcamera.jolt()

    # ========================================
    # Spawn explosion, if necessary, which damages players linearly from
    # its epicenter up to @explosionRadius
    if spawnExplosion
      spawnPos = [@lastPos[0], @lastPos[1]]
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

    if doTeleport
      @teleportEnd(@player, @lastPos[0], @lastPos[1])
      @shost.gcamera.center(@player.sprite)

    if doKillBullet
      if mConfig.GameConstant.debug
        console.log 'bullet died'
      @shost.removeBullet(this)
      @kill()

  kill: () ->
    @sprite.destroy(true)
    @sprite = null
    @entity.kill()
    @entity = null
    for emitter in @attachedEmitters
      if emitter != null
        emitter.on = false
        # kill the emitter in 2 seconds, let particles live for a bit
        @shost.game.time.events.add(2000, emitter.destroy, emitter)
    @attachedEmitters = null

  drawExplosion: (x, y, hitGround) ->
    if @particleEnd != null
      @particleEnd(@shost.game, x, y, hitGround)


class BulletSpecFactory

  @craterRadiusPx = 26

  # This is the basic bullet spec for the simplest bullet.  Other specs 
  # override its values if specified, otherwise will default back to this.
  @basicSpec = {
    # volleys and fire rate
    num_volleys: 1,
    bullets_per_volley: 1,
    delay_bw_volleys: 0,
    delay_in_volleys: 0,
    # bullet and damage
    bullet_image: 'bullet',
    bullet_scale: 0.3,
    collisionRadiusPx: 16,
    craterRadiusPx: @craterRadiusPx,
    # Damage and explosion damage.  If a direct hit is achieved, the hit player
    # gets directHitDamage applied, but is ignored in the explosion damage.
    # All others hit by indirect explosionRadius will incur linearly decreasing
    # explosionMaxDamage based on percentage distance from explosion center
    directHitDamage: 33,
    # note that explosion radius is based on center of bullet to center of
    # player, so need to add at least player sprite width/2 to account for
    # that extra distance
    explosionRadius: 70,
    explosionMaxDamage: 30,
    explosionMinDamage: 10,
    # explosion emitters, calls explosion factory methods to generate explosions
    # at the start of bullet's life, and at the end
    # can also attach emitters for smoke trail effects
    particleStart: (game, x, y) -> 
      em = mEffects.ExplosionFactory.createGlowBasic(game, x, y, 0.3, 0.3)
      return em.concat(mEffects.ExplosionFactory.createSparksBasic(game, x, y, 0.3))
    particleAttach: null,
    particleEnd: (game, x, y, hitground=false) -> 
      if hitground
        em = mEffects.ExplosionFactory.createPebbleBasic(game, x, y, 0.5)
      else
        em = mEffects.ExplosionFactory.createFlareBasic(game, x, y, 0.6)
      return em.concat(mEffects.ExplosionFactory.createExplosionBasic(game, x, y, 0.6))
    # These are special bullet types, e.g., teleportation
    isTeleport: false,
    teleportEnd: (player, x, y) ->
      player.setX(x)
      player.setY(y)
  }

  @allSpecs = {
    # Basic shot
    # Crater: medium
    # Damage: low
    "0": {
      # volleys and fire rate
      num_volleys: 1,
      bullets_per_volley: 1,    # total shots: 1
      # bullet and damage
      bullet_image: 'bullet',
      bullet_scale: 0.3,
      collisionRadiusPx: 16,
      craterRadiusPx: @craterRadiusPx,
      directHitDamage: 33,      # max:    33
      explosionRadius: 70,
      explosionMaxDamage: 30,   # splash: 30 - 10
      explosionMinDamage: 10
    },
    # 4 volleys, not much cratering or splash but good damage on direct hit
    # Crater: small
    # Damage: low
    "1": {
      # volleys and fire rate
      num_volleys: 2,
      bullets_per_volley: 2,    # total shots:  4
      delay_bw_volleys: 0.8,
      delay_in_volleys: 0.25,
      # bullet and damage
      bullet_image: 'missile1',
      bullet_scale: 0.3,
      collisionRadiusPx: 16,
      craterRadiusPx: 20,
      directHitDamage: 13,      # max: 52
      explosionRadius: 60,
      explosionMaxDamage: 8,   # splash: 32 - 24
      explosionMinDamage: 5,
      particleStart: (game, x, y) -> 
        em = mEffects.ExplosionFactory.createGlowBasic(game, x, y, 0.2, 0.1)
        return em.concat(mEffects.ExplosionFactory.createSparksBasic(game, x, y, 0.3))
      particleAttach: (game, x, y) ->
        return mEffects.ExplosionFactory.createSmokeTrailBasic(game, x, y, 0.3, 1.8)
      particleEnd: (game, x, y, hitground=false) ->
        if hitground
          em = mEffects.ExplosionFactory.createPebbleBasic(game, x, y, 0.5)
        else
          em = mEffects.ExplosionFactory.createFlareBasic(game, x, y, 0.6)
        return em.concat(mEffects.ExplosionFactory.createExplosionBasic(game, x, y, 0.5))
    },
    # TELEPORTATION
    "2": {
      bullet_image: 'tbullet',
      bullet_scale: 0.4,
      collisionRadiusPx: 10,
      craterRadiusPx: 0,
      directHitDamage: 0,
      explosionRadius: 0,
      explosionMaxDamage: 0,
      explosionMinDamage: 0,
      particleStart: (game, x, y) -> 
        em = mEffects.ExplosionFactory.createFlareBasic(game, x, y, 0.4)
        return em.concat(mEffects.ExplosionFactory.createSparksBasic(game, x, y, 0.4, 'spark_blue'))
      particleAttach: (game, x, y) ->
        return mEffects.ExplosionFactory.createSmokeTrailBasic(game, x, y, 0.6, 4.0, 'spark_blue', true)
      # These are special bullet types, e.g., teleportation
      isTeleport: true,
      particleEnd: null
    }
  }

  @_getInternalSpec: (wep_str) ->
    res_spec = {}
    wep_spec = @allSpecs[wep_str]
    for spec in Object.keys(@basicSpec)
      if wep_spec.hasOwnProperty(spec)
        res_spec[spec] = wep_spec[spec]
      else
        res_spec[spec] = @basicSpec[spec]
    return res_spec

  @getBulletSpec: (wep_num) ->
    specList = []
    wep = @_getInternalSpec(wep_num.toString())
    for volley in [0...wep.num_volleys]
      for bullet in [0...wep.bullets_per_volley]
        volley_delay = wep.delay_bw_volleys * volley
        bullet_delay = wep.delay_in_volleys * bullet
        specList.push({
          delay: volley_delay + bullet_delay,
          bullet: {
            bullet_image: wep.bullet_image,
            bullet_scale: wep.bullet_scale,
            collisionRadiusPx: wep.collisionRadiusPx,
            craterRadiusPx: wep.craterRadiusPx,
            directHitDamage: wep.directHitDamage,
            explosionRadius: wep.explosionRadius,
            explosionMaxDamage: wep.explosionMaxDamage,
            explosionMinDamage: wep.explosionMinDamage,
            particleStart: wep.particleStart,
            particleAttach: wep.particleAttach,
            particleEnd: wep.particleEnd,
            isTeleport: wep.isTeleport,
            teleportEnd: wep.teleportEnd
          }
        })

    return specList

exports.Bullet = Bullet
exports.BulletSpecFactory = BulletSpecFactory