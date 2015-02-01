mConfig = require 'world/game-config'

class WorldCreator

  @spawnColor = 'rgba(255,51,255,1)'  # Corresponds to #ff33ff
  # hacky way to account for inexplicable pixel data differences on different machines
  @spawnColorAlt = 'rgba(253,66,252,1)'

  @rgbaFormat: (r,g,b,a) ->
    return 'rgba('+r+','+g+','+b+','+a/255.0+')'

  # Input str is e.g., 'rgba(255,120,200,0.5)'
  # return a list of [r,g,b,a] values
  @rgbaFromString: (str) ->
    str = str.replace('rgba','')
    str = str.replace('(','')
    str = str.replace(')','')
    return str.split(',').map(Number)

  @rgbToHex: (r,g,b) ->
    "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)

  @hexToRgb = (hex) ->
    result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    (if result
      r: parseInt(result[1], 16)
      g: parseInt(result[2], 16)
      b: parseInt(result[3], 16)
    else null)

  @loadFromImage: (shost, map_name, client=false) ->

    # XXX need to decouple this image loading from phaser
    img = shost.game.cache.getImage(map_name)
    canvas = document.createElement('canvas')
    context = canvas.getContext('2d')
    # Important!  Need to set canvas width and height to match the
    # image dimensions.  The default CSS canvas dimensions don't match
    # the images, and the resultant drawn image is scaled incorrectly
    # otherwise!
    context.canvas.width = img.width
    context.canvas.height = img.height
    canvas.id = 'datacanvas'
    #document.body.appendChild(canvas)
    canvas.getContext('2d').drawImage(img, 0, 0, img.width, img.height)

    pixelData = canvas.getContext('2d').getImageData(0, 0, img.width, img.height).data

    if client
      world = new WorldClient(shost, img.width, img.height)
    else
      world = new WorldCore(shost, img.width, img.height)
    world.createSurroundingSpace()

    for y in [0..img.height-1]
      for x in [0..img.width-1]
        red = pixelData[((img.width * y) + x) * 4]
        green = pixelData[((img.width * y) + x) * 4 + 1]
        blue = pixelData[((img.width * y) + x) * 4 + 2]
        alpha = pixelData[((img.width * y) + x) * 4 + 3]
        rgba = @rgbaFormat(red, green, blue, alpha)
        # If the point is a spawn point, store it
        if rgba == @spawnColor or rgba == @spawnColorAlt
          world.addSpawnPoint(x, y)
          world.data[x][y] = world.futureData[x][y] = 'rgba(0,0,0,0)'
        else
          world.data[x][y] = world.futureData[x][y] = rgba
    world.render(true)
    return world

class WorldCore

  isAir: (rgbaStr) ->
    alpha = WorldCreator.rgbaFromString(rgbaStr)[3]
    return alpha == 0

  isGround: (rgbaStr) ->
    alpha = WorldCreator.rgbaFromString(rgbaStr)[3]
    return alpha > 0

  _initData: () ->
    for x in [0..@width-1]
      @data[x] = []
      for y in [0..@height-1]
        @data[x][y] = @emptyColor
    # make a deep clone of data into futureData
    @futureData = jQuery.extend(true, [], @data);

  constructor: (@shost, @width, @height, @tileSize=2) ->
    @data = []
    @futureData = []
    # store the spawn positions pairs, e.g., [[x,y], [x,y]], and sort by
    # X position, then use the spawn order passed by the map spec to determine
    # where players should spawn
    @spawnPoints = []
    # can pass in a custom spawn order for the map.  Based on X-sorted
    # spawn points, order in which players should be spawned at points.
    # For example, for 4 spawn points, [0,2,3,1] would spawn the first 2 
    # players at the far ends
    @spawnOrder = [0,1,2,3,4,5,6,7]

    @emptyColor = 'rgba(0,0,0,0)'

    @_initData()

    # The world is offset from (0,0), so need to take offsets into 
    # consideration when grabbing pixel values
    @offX = 0
    @offY = 0

    # set this to true when actions that deform the map happen, such as 
    # creating craters
    @dirty = false

    
    # XXX Need to decouple this from phaser
    @bmp = @shost.game.make.bitmapData(@width*@tileSize, @height*@tileSize)
    
    @render(true)

  addSpawnPoint: (x, y) ->
    @spawnPoints.push([
      (x + @offX) * @tileSize, (y + @offY) * @tileSize])
    sortBy = (a, b) ->
      if a[0] < b[0]
        return -1
      else if a[0] > b[0]
        return 1
      else
        return a[1] > b[1]
    @spawnPoints.sort (a,b) ->
      sortBy(a, b)

  setSpawnOrder: (order) ->
    # If there are less spawn orders than spawn points, then ignore the order
    # passed in and set a default
    if order.length < @spawnPoints.length
      @spawnOrder = []
      for i in [0...@spawnPoints.length]
        @spawnOrder.push(i)
    # If there are more spawn orders than spawn points, remove the unnecessary
    # ones
    else if order.length > @spawnPoints.length
      @spawnOrder = []
      for num in order
        if num < @spawnPoints.length
          @spawnOrder.push(num)
    else
      @spawnOrder = order

  # getSpawnForPlayerNum: (num) ->
  #   if num >= @spawnPoints.length
  #     return null
  #   spawn_i = 0
  #   for i in [0...@spawnOrder.length]
  #     if @spawnOrder[i] == num
  #       spawn_i = i
  #       break
  #   return @spawnPoints[spawn_i]

  createSurroundingSpace: () ->
    # The play area of the world, brought in by the image, will take up
    # @width*@tileSize, @height*@tileSize pixels.
    # However, we want there to be empty air to both sides of it, and
    # above and below, so as to give the camera space to move.

    console.log 'CREATE SURROUNDING SPACE CORE'

    playWidthPx = @width * @tileSize
    playHeightPx = @height * @tileSize

    horzPaddingPx = playWidthPx / 4
    topPaddingPx = playHeightPx * 0.3
    botPaddingPx = playHeightPx * 0.3

    @gameXBoundL = 0 - 40 # add a few more for good measure so things disappear outside camera
    @gameXBoundR = (playWidthPx + horzPaddingPx*2) * mConfig.GameConstant.cameraScale + 40
    @gameYBound = (playHeightPx + topPaddingPx + botPaddingPx) * mConfig.GameConstant.cameraScale
    @gameYBound += 160  # add a few more for good measure so things disappear
                        # outside of camera

    @offX = horzPaddingPx / @tileSize
    @offY = topPaddingPx / @tileSize

  createCrater: (tileX, tileY, radius) ->
    for x in [-radius..radius]
      for y in [-radius..radius]
        # draw only pixels in circle
        distanceSquared = x*x + y*y
        if distanceSquared < radius*radius
          drawTileX = Phaser.Math.clamp(tileX + x, 0, @width-1)
          drawTileY = Phaser.Math.clamp(tileY + y, 0, @height-@tileSize-1)
          @futureData[drawTileX][drawTileY] = @emptyColor
    @dirty = true
    null

  handleClick: (tileX, tileY) ->
    # do nothing for now
    null

  render: (force=false) ->
    if !force && !@dirty
      return
    for x in [0..@width-1]
      for y in [0..@height-1]
        if @data[x][y] != @futureData[x][y] || force
          @data[x][y] = @futureData[x][y]
          @_drawTilePixel(@data[x][y], x, y)
          @bmp.dirty = true
    @dirty = false
    true

  xTileForWorld: (world) ->
    Math.floor(world / @tileSize - @offX)

  yTileForWorld: (world) ->
    Math.floor(world / @tileSize - @offY)

  xWorldForTile: (tile) ->
    Math.floor(tile * @tileSize + @offX * @tileSize)

  yWorldForTile: (tile) ->
    Math.floor(tile * @tileSize + @offY * @tileSize)

  # Given pixel space in the world, convert to tile space and return
  # the rgba
  getRgbaForWorldXY: (x, y) ->
    tileX = @xTileForWorld(x)
    tileY = @yTileForWorld(y)
    if tileX < 0 || tileX >= @width
      return @emptyColor
    if tileY < 0 || tileY >= @height
      return @emptyColor
    return @data[tileX][tileY]

  getRgbaForTileXY: (x, y) ->
    if x < 0 || x >= @width
      return @emptyColor
    if y < 0 || y >= @height
      return @emptyColor
    return @data[x][y]

  highestNonFreeYTile: (x, y) ->
    if x < 0 || x >= @width
      return 0
    if y < 0 || y >= @height
      return 1
    currentY = y
    while currentY >= 0
      break if @isAir(@data[x][currentY])
      currentY -= 1
    currentY + 1

  _drawTilePixel: (color, x, y) ->
    @bmp.ctx.clearRect(@tileSize * x, @tileSize * y, @tileSize, @tileSize)
    @bmp.ctx.fillStyle = color
    @bmp.ctx.fillRect(@tileSize * x, @tileSize * y, @tileSize, @tileSize)

class WorldClient extends WorldCore

  constructor: (@shost, @width, @height, @tileSize=2) ->
    super @shost, @width, @height, @tileSize

    @sprite = new Phaser.Sprite(@shost.game, 0, 0, @bmp)
    @sprite.body = null
    @shost.playgroup.add(@sprite)

    @initBackground()

  createSurroundingSpace: () ->
    super

    # XXX This is bad, code is duplicated from WorldCore
    playWidthPx = @width * @tileSize
    playHeightPx = @height * @tileSize

    horzPaddingPx = playWidthPx / 4
    topPaddingPx = playHeightPx * 0.3
    botPaddingPx = playHeightPx * 0.3

    @shost.game.world.setBounds(
      0, 
      0, 
      (playWidthPx + horzPaddingPx*2) * mConfig.GameConstant.cameraScale, 
      (playHeightPx + topPaddingPx + botPaddingPx) * mConfig.GameConstant.cameraScale)

    console.log 'bounds should be ' 
    console.log playWidthPx + horzPaddingPx*2
    console.log playHeightPx + topPaddingPx + botPaddingPx

    @sprite.x = horzPaddingPx
    @sprite.y = topPaddingPx

  testClickGround: () ->
    # For testing, mouse clicks destroy ground
    if @sprite.input.pointerDown()
      tileX = @tileForWorld(@sprite.input.pointerX())
      tileY = @tileForWorld(@sprite.input.pointerY())
      @handleClick(tileX, tileY)
    else if @sprite.input.pointerDown(1)
      # needed for touch events
      tileX = @tileForWorld(@sprite.input.pointerX(1))
      tileY = @tileForWorld(@sprite.input.pointerY(1))
      @handleClick(tileX, tileY)

  # GRAPHICAL BACKGROUND INITIALIZATION
  # This stuff only applies to client Phaser state, and is the background and 
  # midground parallax effects
  initBackground: ->
    @bggroup = @shost.game.add.group()

    @background = new Phaser.Sprite(@shost.game, 0, 0, 'background')
    # disable physics for background sprite
    @background.body = null
    @background.fixedToCamera = true
    bgX = @shost.game.stage.bounds.width / @background.width \
    / mConfig.GameConstant.cameraScale * mConfig.GameConstant.backgroundImageScale
    bgY = @shost.game.stage.bounds.height / @background.height \
    / mConfig.GameConstant.cameraScale * mConfig.GameConstant.backgroundImageScale
    @background.scale.set(bgX, bgY)
    @bggroup.add(@background)

    @mggroup = @shost.game.add.group()
    @mggroup.fixedToCamera = true
    cloud_pos = [[300, 300, 1.4], [800, 500, 1.7], [1300,120, 1.5]]
    for pos in cloud_pos
      cloud = new Phaser.Sprite(@shost.game, pos[0], pos[1], 'cloud1')
      cloud.body = null
      #cloud.fixedToCamera = true
      cloud.scale.set(pos[2], pos[2])
      cloud.alpha = 0.8
      @mggroup.add(cloud)


# don't need to export World, only WorldCreator
# in effect keeping World private and forcing external
# modules to use WorldCreator factory
exports.WorldCreator = WorldCreator