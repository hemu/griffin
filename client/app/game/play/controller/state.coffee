State =
  INIT: 0      # loading level, before games starts
  SETUP: 1     # before turn begins
  INPUT: 2     # current turn, player is aiming, moving
  REACT: 3     # current turn, player has acted, watching reaction
  CLEANUP: 4   # current turn ending
  TURN_WAIT: 5 # not current turn, waiting for other player turns to complete


module.exports = State