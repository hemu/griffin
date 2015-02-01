mInput = require 'input/game-input'
mUi = require 'ui/game-ui'
mWorld = require 'world/world'
mConfig = require 'world/game-config'
mCam = require 'world/game-camera'
mPlayer = require 'entity/player'
State = require 'controller/state'

class PlayControllerCore

  constructor: (@sessionController) ->
    # ================================
    # CORE
    @sessionId = null  # The player's secret session id, known only to him
    @players = []   # array of Player objects
    @bullets = []
    @active_player = null
    @game_time_remaining = 0

    # p2.js world which runs our physics simulation
    @p2world = null
    @gameOver = false
    @setState(State.INIT)

  setState: (newState) ->
    @state = newState

  getState: ->
    return @state

  initialize: (initConfig, client=false) ->
    @setState(State.SETUP)

    # Setup world
    # This is our own game logic World class, not to be confused with
    # Phaser's built in @game.world
    @world = mWorld.WorldCreator.loadFromImage(this, 'world_divide', client)
    @world.setSpawnOrder([2,0,1,3])

    # This is the p2 physics simulated world, which is where the
    # physics representations of the players and bullets etclive.
    # p2world holds the ground truth of where objects in the scene
    # live, we only use Phaser for drawing sprites at their locations.
    @p2world = new p2.World()
    @p2world.gravity = [0,0]

    num_players = 0
    
    # initConfig
    # {
    #    init: 
    #      id0: 
    #        pos: [x0, y0]
    #      id1:
    #        pos: [x1, y1]
    #    myid: "Awkjhds72jds2sd"
    #    turn: "Awkjhds72jds2sd"
    # }

    @sessionId = initConfig['myid']

    # XXX Need to further refactor this in future as Player class is separated
    # into core and client versions as well
    for own id,playerConfig of initConfig['init']
      # for now just set the name same as id
      name = id
      spawnPos = playerConfig['pos']
      if spawnPos == undefined or spawnPos == null
        throw new Error "spawn position not found for player #{id}"
      # instantiate player objects and add to @players list
      if client
        player = new mPlayer.PlayerClient(this)
      else
        player = new mPlayer.PlayerCore(this)
      player.initialize(this, id, spawnPos[0], spawnPos[1],
        mConfig.GameConstant.playerScale, 0)
      #player.initReticule()
      player.initHealth(200)
      player.setName(name)
      @players.push player

      num_players++

    @game_time_remaining = mConfig.GameConstant.turnTime

    # Disable player-to-player p2 body collisions.  For every pairing of 
    # players, disable collisions
    if num_players > 1
      i = 0
      while true
        for j in [i..num_players-1]
          if j != i
            @p2world.disableBodyCollision(@players[i].entity.p2body, @players[j].entity.p2body)
        i += 1
        if i == num_players
          break

    @active_player = @players[0]
    @active_player.active = true

  changeTurn: (turnConfig) ->
    console.log turnConfig
    console.log 'MY SESSION ID'
    console.log @sessionId
    activeId = turnConfig['tid']
    if @sessionId == activeId
      console.log 'MY TURN'
      @setState(State.INPUT)
    else
      console.log 'NOT MY TURN'
      @setState(State.TURN_WAIT)

  render: ->
    @world.render()

  update: (dt) ->
    # step p2world for physics simulation to occur
    @p2world.step(dt)

    if @gameOver
      return false

    for player in @players
      player.update(dt, @world)

    for bullet in @bullets
      if bullet != null
        bullet.update(@world)

    return true

  playerMoveLeft: (dt) ->
    @active_player.moveLeft(dt, @world)

  playerMoveRight: (dt) ->
    @active_player.moveRight(dt, @world)

  playerAimUp: (dt) ->
    @active_player.aimUp(dt)

  playerAimDown: (dt) ->
    @active_player.aimDown(dt)

  playerChargeShot: (dt) ->
    @active_player.chargeShot(dt)

  playerFire: ->
    @active_player.fire()

  playerSetWeapon: (num) ->
    if @active_player == null
      return
    @active_player.setWeapon(num)

  removePlayer: (rplayer) ->
    console.log 'REMOVING PLAYER'
    console.log rplayer
    if @active_player == rplayer
      @active_player = null
    # first remove reference to player
    remaining_players = []
    for player in @players
      if player != rplayer
        remaining_players.push(player)
    @players = remaining_players

    if @players.length == 1
      @gameOver = true
      return

  removeBullet: (removeBullet) ->
    remaining_bullets = []
    for bullet in @bullets
      if bullet != removeBullet
        remaining_bullets.push(bullet)      
    @bullets = remaining_bullets

class PlayControllerClient extends PlayControllerCore

  constructor: (@game, @sessionController) ->

    super @sessionController

    # ================================
    # CLIENT
    # Almost all of the sprites in game go in here, besides the background
    # image and midground graphics, and the ui
    @playgroup = @game.add.group()
    # game camera
    @gcamera = null

  initialize: (initConfig) ->

    super initConfig, true
    
    mInput.GameInput.controller = this
    mInput.GameInput.setupInputs()
    mUi.GameUI.initialize(this)
    
    # for particle physics
    @game.physics.startSystem(Phaser.Physics.ARCADE)

    @game.camera.scale.set(
      mConfig.GameConstant.cameraScale,
      mConfig.GameConstant.cameraScale
      )

    @game.world.bringToTop(@playgroup)

    @gcamera = new mCam.GameCamera(this)
    @gcamera.initialize(1.0)
    
    @active_player.showUI()
    @refreshUI()
    @gcamera.follow(@active_player.sprite)
    @gcamera.easeTo(@active_player.getX() - @game.width/2, @active_player.getY() - @game.height/2)

    mUi.GameUI.bringToTop()
  
  update: (dt) ->
    result = super dt
    
    if @gameOver
      return
    
    @gcamera.update(dt)

    if @game_time_remaining > 0
      oldtime = Math.floor(@game_time_remaining)
      @game_time_remaining -= dt
      newtime = Math.ceil(@game_time_remaining)
      if oldtime != newtime
        mUi.GameUI.updateTurnTime(newtime)
      if @game_time_remaining <= 0
        mUi.GameUI.updateTurnTime(0)

    if @active_player == null
      return

    mInput.GameInput.update(dt)

    mUi.GameUI.updateMoveBar(
      @active_player.cur_move_points / @active_player.max_move_points)
    mUi.GameUI.updateShotBar(
      @active_player.cur_shot_points / @active_player.max_shot_points)

  playerMoveLeft: (dt) ->
    super dt
    @gcamera.follow(@active_player.sprite)

  playerMoveRight: (dt) ->
    super dt
    @gcamera.follow(@active_player.sprite)

  playerChargeShot: (dt) ->
    super dt
    mUi.GameUI.updateChargeBar(
      @active_player.cur_charge / @active_player.max_charge)

  playerFire: ->
    super
    mUi.GameUI.updateChargeBar(0)
    mUi.GameUI.refreshChargeSave(@active_player.last_charge / @active_player.max_charge)
    mInput.GameInput.spaceIsDown = false
    mUi.GameUI.refreshWeaponUI(@active_player.wep_num)

  playerMoveCamera: (x, y) ->
    @gcamera.playerMoveCamera(x, y)

  playerReleaseCamera: ->
    @gcamera.playerReleaseCamera()

  refreshUI: ->
    mUi.GameUI.updateMoveBar(
      1.0 - @active_player.cur_movement / @active_player.max_movement)
    mUi.GameUI.updateChargeBar(0)
    mUi.GameUI.refreshChargeSave(@active_player.last_charge / @active_player.max_shot_charge)
    mInput.GameInput.spaceIsDown = false
    mUi.GameUI.refreshWeaponUI(@active_player.wep_num)

  removePlayer: (rplayer) ->
    super rplayer
    console.log 'CLIENT REMOVE PLAYER'
    console.log @players.length
    console.log @gameOver
    if @gameOver
      @gameOverText = new Phaser.Text(@game, 500, 300, 'Game Over')
      @gcamera.addFixedSprite(@gameOverText)


exports.PlayControllerCore = PlayControllerCore
exports.PlayControllerClient = PlayControllerClient