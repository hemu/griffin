Event =
  INIT_GAME: 'ig'
  CHANGE_TURN: 'ct'

Message =
  UPDATE: 'up'

# might need to split these up
# with more semantic grouping
MessageKey =
  EVENT: 'evt'
  DATA: 'dt'
  TURN: 'tid'
  INIT: 'init'
  POS: 'p'
  FACING_DIR: 'fd'

module.exports.Event = Event
module.exports.Message = Message
module.exports.MessageKey = MessageKey