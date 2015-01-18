Event =
  INIT_GAME: 'ig'
  CHANGE_TURN: 'ct'

Message =
  UPDATE: 'up'

# might need to split these up
# with more semantic grouping
MessageKey =
  EVENT: 'evt'      # generic event key
  DATA: 'dt'        # generic data key
  TURN: 'tid'       # current turn player id
  INIT: 'init'      # initialize game
  POS: 'p'          # player position
  FACING_DIR: 'fd'  # player facing direction

module.exports.Event = Event
module.exports.Message = Message
module.exports.MessageKey = MessageKey