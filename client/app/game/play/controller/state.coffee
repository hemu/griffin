State =
  SETUP: 0
  # current turn, player is aiming, moving
  INPUT: 1
  # current turn, player has acted, watching reaction
  # e.g. projectile flying
  INPUT_REACT: 2
  # current turn ending
  TURN_END: 3
  # not current turn, waiting for other player turns to complete
  TURN_WAIT: 4


module.exports = State