class @BulletSpecFactory

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
    bullet_scale: 0.4,
    collisionRadiusPx: 20,
    craterRadiusPx: 50,
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
    # can also attach emitters for smoke trail effect
    particleStart: (game, x, y) -> 
      em = ExplosionFactory.createGlowBasic(game, x, y, 0.7, 0.3)
      return em.concat(ExplosionFactory.createSparksBasic(game, x, y, 0.8))
    particleAttach: null,
    particleEnd: (game, x, y, hitground=false) -> 
      if hitground
        em = ExplosionFactory.createPebbleBasic(game, x, y, 1)
      else
        em = ExplosionFactory.createFlareBasic(game, x, y, 1)
      return em.concat(ExplosionFactory.createExplosionBasic(game, x, y, 1))
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
      bullet_scale: 0.4,
      collisionRadiusPx: 20,
      craterRadiusPx: 50,
      directHitDamage: 33,      # max:    33
      explosionRadius: 80,
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
      bullet_scale: 0.4,
      collisionRadiusPx: 20,
      craterRadiusPx: 36,
      directHitDamage: 13,      # max: 52
      explosionRadius: 60,
      explosionMaxDamage: 8,   # splash: 32 - 24
      explosionMinDamage: 6,
      particleStart: (game, x, y) -> 
        em = ExplosionFactory.createGlowBasic(game, x, y, 0.4, 0.1)
        return em.concat(ExplosionFactory.createSparksBasic(game, x, y, 0.5))
      particleAttach: (game, x, y) ->
        return ExplosionFactory.createSmokeTrailBasic(game, x, y, 0.6)
      particleEnd: (game, x, y, hitground=false) ->
        if hitground
          em = ExplosionFactory.createPebbleBasic(game, x, y, 0.7)
        else
          em = ExplosionFactory.createFlareBasic(game, x, y, 0.7)
        return em.concat(ExplosionFactory.createExplosionBasic(game, x, y, 0.7))
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
            particleEnd: wep.particleEnd
          }
        })

    return specList