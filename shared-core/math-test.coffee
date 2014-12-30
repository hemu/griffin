square = require('./square')
gameMath = require('./game-math')

module.exports = ->
  console.log "#########  Shared module example #########"
  console.log(square(10))
  console.log(gameMath)