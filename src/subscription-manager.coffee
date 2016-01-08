class SubscriptionManager
  constructor: ({@datastore,@uuidAliasResolver}) ->

  subscriberList: ({subscriberUuid}, callback) =>
    @uuidAliasResolver.resolve subscriberUuid, (error, subscriberUuid) =>
      return callback error if error?

      query = {subscriberUuid}
      @datastore.find query, callback

  subscriberListForType: ({subscriberUuid, type}, callback) =>
    @uuidAliasResolver.resolve subscriberUuid, (error, subscriberUuid) =>
      return callback error if error?

      query = {subscriberUuid, type}
      @datastore.find query, callback

  emitterList: ({emitterUuid}, callback) =>
    @uuidAliasResolver.resolve emitterUuid, (error, emitterUuid) =>
      return callback error if error?

      query = {emitterUuid}
      @datastore.find query, callback

  emitterListForType: ({emitterUuid, type}, callback) =>
    @uuidAliasResolver.resolve emitterUuid, (error, emitterUuid) =>
      return callback error if error?

      query = {emitterUuid, type}
      @datastore.find query, callback

module.exports = SubscriptionManager
