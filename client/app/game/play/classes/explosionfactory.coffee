class @ExplosionFactory

  @createExplosionBasic: (game, x, y) ->
    @createBlastBasic(game, x, y)
    @createSparksBasic(game, x, y)
    #@createGlowBasic(game, x, y)
    @createRingBasic(game, x, y)

  # A tumbling red orange yellow direct blast explosion, part normal blend,
  # part add blend (bright)
  @createBlastBasic: (game, x, y) ->
    # ============================
    # Explosion blast
    numBlasts = 1
    blastLifetimeMs = 1000
    blastAEmitter = game.add.emitter(x, y, numBlasts)
    blastAEmitter.blendMode = Phaser.blendModes.NORMAL
    blastAEmitter.makeParticles('explosion')
    blastAEmitter.gravity = 0
    blastAEmitter.setXSpeed(-60, 60)
    blastAEmitter.setYSpeed(-20, -40)
    blastAEmitter.setAlpha(1.0, 0, blastLifetimeMs, Phaser.Easing.Linear.In)
    blastAEmitter.setScale(1.6, 2.0, 1.6, 2.0, blastLifetimeMs, Phaser.Easing.Linear.In)
    # explode, lifespan (ms), frequency, quantity, forceQuantity
    blastAEmitter.start(false, blastLifetimeMs, 60, numBlasts)

    blastEmitter = game.add.emitter(x, y, numBlasts)
    blastEmitter.blendMode = Phaser.blendModes.ADD
    blastEmitter.makeParticles('explosion')
    blastEmitter.gravity = -80
    blastEmitter.setXSpeed(-60, 60)
    blastEmitter.setYSpeed(-20, -40)
    blastEmitter.setAlpha(0.8, 0, blastLifetimeMs, Phaser.Easing.Linear.In)
    blastEmitter.setScale(1.6, 2.0, 1.6, 2.0, blastLifetimeMs, Phaser.Easing.Linear.In)
    # explode, lifespan (ms), frequency, quantity, forceQuantity
    blastEmitter.start(false, blastLifetimeMs, 60, numBlasts)

  # Flying sparks exploding from a single point
  @createSparksBasic: (game, x, y) ->
    numSparks = 32
    sparkLifetimeMs = 1200
    sparkEmitter = game.add.emitter(x, y, numSparks)
    sparkEmitter.blendMode = Phaser.blendModes.ADD
    sparkEmitter.makeParticles('spark')
    sparkEmitter.gravity = 300
    sparkEmitter.setXSpeed(-200, 200)
    sparkEmitter.setYSpeed(-300, 100)
    sparkEmitter.setAlpha(1, 0.1, sparkLifetimeMs, Phaser.Easing.Quintic.In)
    sparkEmitter.setScale(1.2, 0.6, 1.2, 0.6, sparkLifetimeMs, Phaser.Easing.Quintic.In)
    # explode, lifespan (ms), frequency, quantity, forceQuantity
    sparkEmitter.start(true, sparkLifetimeMs, null, numSparks)

  # Large lingering glow
  @createGlowBasic: (game, x, y) ->
    numGlow = 1
    glowLifetimeMs = 3000
    glowEmitter = game.add.emitter(x, y, numGlow)
    glowEmitter.blendMode = Phaser.blendModes.ADD
    glowEmitter.makeParticles('glow')
    glowEmitter.gravity = 0
    glowEmitter.setXSpeed(-0, 0)
    glowEmitter.setYSpeed(-0, 0)
    glowEmitter.setRotation(0,0)
    glowEmitter.setAlpha(0.6, 0, glowLifetimeMs, Phaser.Easing.Linear.In)
    glowEmitter.setScale(10, 8, 10, 8, glowLifetimeMs, Phaser.Easing.Linear.In)
    # explode, lifespan (ms), frequency, quantity, forceQuantity
    glowEmitter.start(true, glowLifetimeMs, null, numGlow)

  # Large expanding ring
  @createRingBasic: (game, x, y) ->
    numRing = 1
    ringLifetimeMs = 800
    ringEmitter = game.add.emitter(x, y, numRing)
    ringEmitter.blendMode = Phaser.blendModes.ADD
    ringEmitter.makeParticles('ring')
    ringEmitter.gravity = 0
    ringEmitter.setXSpeed(-0, 0)
    ringEmitter.setYSpeed(-0, 0)
    ringEmitter.setRotation(0,0)
    ringEmitter.setAlpha(0.8, 0, ringLifetimeMs, Phaser.Easing.Linear.Out)
    ringEmitter.setScale(2, 7, 2, 7, ringLifetimeMs, Phaser.Easing.Linear.Out)
    # explode, lifespan (ms), frequency, quantity, forceQuantity
    ringEmitter.start(true, ringLifetimeMs, null, numRing)

  @createFlareBasic: (game, x, y) ->
    numFlare = 1
    flareLifetimeMs = 1000
    flareEmitter = game.add.emitter(x, y, numFlare)
    flareEmitter.blendMode = Phaser.blendModes.ADD
    flareEmitter.makeParticles('flare')
    flareEmitter.gravity = 0
    flareEmitter.setXSpeed(-0, 0)
    flareEmitter.setYSpeed(-0, 0)
    flareEmitter.setRotation(0,0)
    flareEmitter.minParticleScale = 6
    flareEmitter.maxParticleScale = 6
    flareEmitter.setAlpha(0.7, 0, flareLifetimeMs, Phaser.Easing.Linear.Out)
    #flareEmitter.scale = 10
    #flareEmitter.setScale(10, 10, 10, 10, flareLifetimeMs, Phaser.Easing.Linear.Out)
    # explode, lifespan (ms), frequency, quantity, forceQuantity
    flareEmitter.start(true, flareLifetimeMs, null, numFlare)

  @createPebbleBasic: (game, x, y) ->
    numPebble = 16
    pebbleLifetimeMs = 1200
    pebbleEmitter = game.add.emitter(x, y, numPebble)
    pebbleEmitter.setSize(40,40)
    pebbleEmitter.blendMode = Phaser.blendModes.NORMAL
    pebbleEmitter.makeParticles('pebble')
    pebbleEmitter.gravity = 800
    pebbleEmitter.setXSpeed(-200, 200)
    pebbleEmitter.setYSpeed(-400, -100)
    pebbleEmitter.minParticleScale = 0.3
    pebbleEmitter.maxParticleScale = 1.0
    pebbleEmitter.setAlpha(1.0, 0.2, pebbleLifetimeMs, Phaser.Easing.Quintic.In)
    #pebbleEmitter.scale = 10
    #pebbleEmitter.setScale(10, 10, 10, 10, pebbleLifetimeMs, Phaser.Easing.Linear.Out)
    # explode, lifespan (ms), frequency, quantity, forceQuantity
    pebbleEmitter.start(true, pebbleLifetimeMs, null, numPebble)


    