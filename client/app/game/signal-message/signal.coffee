# channel = postal.channel()
# subscription = channel.subscribe "name.change", (data) ->
#     console.log(data.name)
# channel.publish "name.change", name : "Dr. Who"
# subscription.unsubscribe()

Channel =
  SETUP: 'game.setup'

Signal =
  START: 'st'
  IN_JOIN: 'ij'

Key = 'msg'

module.exports.Channel = Channel
module.exports.Signal = Signal
module.exports.Key = Key