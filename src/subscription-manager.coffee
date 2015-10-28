class SubscriptionManager
  constructor: (dependencies={}) ->
    {@subscriptions} = dependencies.database

  list: (subscriberUuid, callback) =>
    query =
      subscriberUuid: subscriberUuid
    @subscriptions.find query, callback
    
module.exports = SubscriptionManager
