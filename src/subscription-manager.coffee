class SubscriptionManager
  constructor: ({@datastore,@uuidAliasResolver}) ->

  list: (subscriberUuid, callback) =>
    @uuidAliasResolver.resolve subscriberUuid, (error, subscriberUuid) =>
      return callback error if error?
      
      query = {subscriberUuid}
      @datastore.find query, callback

module.exports = SubscriptionManager
