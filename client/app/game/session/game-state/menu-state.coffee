class MainMenuState extends Phaser.State
	constructor: -> super

	create: ->
		# @logo = new LogoSprite(@game, 
		# 					   @game.world.centerX,
		# 					   -300,
		# 					   "logo")
		# @game.world.add(@logo)

		# @game.add.tween(@logo)
		# 	.to(y: 800, 3000, Phaser.Easing.Linear.None, true)
		# 	.onComplete.add @startGame, true
		@startGame()

	startGame: =>
		@game.state.start "Join", true, false

exports.MainMenuState = MainMenuState