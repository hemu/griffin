class BootState extends Phaser.State
  
  constructor: -> 
    super
    console.log "Boot state constructor"

  preload: ->
    console.log "Boot state preload"
    @assetPrefix = "assets/images/"
    @game.load.image("preloader", @getAssetPath("loader.png"))

  create: ->
    console.log "Boot state create"
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