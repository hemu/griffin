class BootState extends Phaser.State
  
  constructor: -> 
    super

  preload: ->
    @assetPrefix = "assets/images/"
    @game.load.image("preloader", @getAssetPath("loader.png"))

  create: ->
    # Put any game/screen configuration logic here
    # switch
    #   when @game.device.desktop;
    #   when @game.device.android;
    #   when @game.device.iOS;
    #   when @game.device.linux;
    #   when @game.device.macOS;

    @game.state.start "Preloader", true, false

  getAssetPath: (asset) =>
    return (@assetPrefix + asset)

exports.BootState = BootState