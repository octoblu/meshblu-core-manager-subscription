class SubscriptionManager
  constructor: ({@datastore}) ->

  list: (subscriberUuid, callback) =>
    query =
      subscriberUuid: subscriberUuid
    @datastore.find query, callback

module.exports = SubscriptionManager
