class @WorldCreator
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

  @loadFromImage: (shost) ->
    # XXX need to decouple this image loading from phaser
    img = shost.game.cache.getImage("ground")
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

    world = new World(shost, img.width, img.height)

    for y in [0..img.height-1]
      for x in [0..img.width-1]
        red = pixelData[((img.width * y) + x) * 4]
        green = pixelData[((img.width * y) + x) * 4 + 1]
        blue = pixelData[((img.width * y) + x) * 4 + 2]
        alpha = pixelData[((img.width * y) + x) * 4 + 3]
        rgba = @rgbaFormat(red, green, blue, alpha)
        #if rgba == spawnColor
        #do stuff with spawn, etc
        world.data[x][y] = world.futureData[x][y] = rgba
    world.render(true)
    return world

class @World

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

    @emptyColor = 'rgba(0,0,0,0)'

    @_initData()

    # The world is offset from (0,0), so need to take offsets into 
    # consideration when grabbing pixel values
    @offX = 0
    @offY = 0

    @bmp = @shost.game.make.bitmapData(@width*@tileSize, @height*@tileSize)
    @sprite = new Phaser.Sprite(@shost.game, 0, 0, @bmp)
    @sprite.inputEnabled = true
    @sprite.events.onInputDown.add(() =>
    console.log('sprite input Down'))
    @shost.playgroup.add(@sprite)
    @render(true)

    @createSurroundingSpace()

  createSurroundingSpace: () ->
    # The play area of the world, brought in by the image, will take up
    # @width*@tileSize, @height*@tileSize pixels.
    # However, we want there to be empty air to both sides of it, and
    # above and below, so as to give the camera space to move.

    playWidthPx = @width * @tileSize
    playHeightPx = @height * @tileSize

    horzPaddingPx = playWidthPx / 4
    topPaddingPx = playHeightPx * 1.5
    botPaddingPx = playHeightPx

    @shost.game.world.setBounds(
      0, 
      0, 
      (playWidthPx + horzPaddingPx*2) * GameConstants.cameraScale, 
      (playHeightPx + topPaddingPx + botPaddingPx) * GameConstants.cameraScale)

    @gameXBoundL = 0 - 40 # add a few more for good measure so things disappear outside camera
    @gameXBoundR = (playWidthPx + horzPaddingPx*2) * GameConstants.cameraScale + 40
    @gameYBound = (playHeightPx + topPaddingPx + botPaddingPx) * GameConstants.cameraScale
    @gameYBound += 160  # add a few more for good measure so things disappear
                        # outside of camera

    console.log 'bounds should be ' 
    console.log playWidthPx + horzPaddingPx*2
    console.log playHeightPx + topPaddingPx + botPaddingPx

    @offX = horzPaddingPx / @tileSize
    @offY = topPaddingPx / @tileSize
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

  createCrater: (tileX, tileY, radius) ->
    for x in [-radius..radius]
      for y in [-radius..radius]
        # draw only pixels in circle
        distanceSquared = x*x + y*y
        if distanceSquared < radius*radius
          drawTileX = Phaser.Math.clamp(tileX + x, 0, @width-1)
          drawTileY = Phaser.Math.clamp(tileY + y, 0, @height-@tileSize-1)
          @futureData[drawTileX][drawTileY] = @emptyColor
    null

  handleClick: (tileX, tileY) ->
    # do nothing for now
    null

  render: (force=false) ->
    for x in [0..@width-1]
      for y in [0..@height-1]
        if @data[x][y] != @futureData[x][y] || force
          @data[x][y] = @futureData[x][y]
          @_drawTilePixel(@data[x][y], x, y)
          @bmp.dirty = true
    true

  xTileForWorld: (world) ->
    Math.floor(world / @tileSize) - @offX

  yTileForWorld: (world) ->
    Math.floor(world / @tileSize) - @offY

  xWorldForTile: (tile) ->
    Math.floor(tile * @tileSize) + @offX * @tileSize

  yWorldForTile: (tile) ->
    Math.floor(tile * @tileSize) + @offY * @tileSize

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

