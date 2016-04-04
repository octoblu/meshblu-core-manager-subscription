class SubscriptionManager
  @TYPES: [
    'broadcast'
    'config'
    'received'
    'sent'
    'broadcast.received'
    'broadcast.sent'
    'configure.received'
    'configure.sent'
    'message.received'
    'message.sent'
  ]
  constructor: ({@datastore,@uuidAliasResolver}={}) ->
    throw new Error('datastore is required') unless @datastore?
    throw new Error('uuidAliasResolver is required') unless @uuidAliasResolver?

  create: ({subscriberUuid, emitterUuid, type}, callback) =>
    return callback @_createUserError 'Missing subscriberUuid', 422 unless subscriberUuid?
    return callback @_createUserError 'Missing emitterUuid', 422 unless emitterUuid?
    return callback @_createUserError 'Missing type', 422 unless type?
    return callback @_createUserError 'Invalid type', 422 unless type in SubscriptionManager.TYPES

    @uuidAliasResolver.resolve emitterUuid, (error, emitterUuid) =>
      return callback @_createUserError error.message if error?
      @uuidAliasResolver.resolve subscriberUuid, (error, subscriberUuid) =>
        return callback @_createUserError error.message if error?
        @datastore.findOne {subscriberUuid,emitterUuid,type}, (error, subscription) =>
          return callback @_createUserError error.message if error?
          return callback @_createUserError 'Subscription already exists', 304 if subscription?
          @datastore.insert {subscriberUuid,emitterUuid,type}, callback

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

  remove: ({subscriberUuid, emitterUuid, type}, callback) =>
    return callback @_createUserError 'Missing subscriberUuid', 422 unless subscriberUuid?
    return callback @_createUserError 'Missing emitterUuid', 422 unless emitterUuid?
    return callback @_createUserError 'Missing type', 422 unless type?
    return callback @_createUserError 'Invalid type', 422 unless type in ['broadcast', 'config', 'received', 'sent']

    @uuidAliasResolver.resolve emitterUuid, (error, emitterUuid) =>
      return callback @_createUserError error.message if error?
      @uuidAliasResolver.resolve subscriberUuid, (error, subscriberUuid) =>
        return callback @_createUserError error.message if error?
        @datastore.remove {subscriberUuid,emitterUuid,type}, callback

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

  _createUserError: (message, code) =>
    error = new Error message
    error.code = code || 500
    return error

module.exports = SubscriptionManager
