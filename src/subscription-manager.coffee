_ = require 'lodash'

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
    'unregister.sent'
    'unregister.received'
  ]
  @PROJECTION: {
    _id: false,
    subscriberUuid: true,
    emitterUuid: true,
    type: true,
  }
  constructor: ({@datastore,@uuidAliasResolver}={}) ->
    throw new Error('datastore is required') unless @datastore?
    throw new Error('uuidAliasResolver is required') unless @uuidAliasResolver?

  create: ({subscriberUuid, emitterUuid, type}, callback) =>
    @exists {subscriberUuid, emitterUuid, type}, (error, exists) =>
      return callback error if error?
      return callback @_createUserError 'Subscription already exists', 304 if exists
      @datastore.upsert {subscriberUuid,emitterUuid,type}, {subscriberUuid,emitterUuid,type}, callback

  emitterList: ({emitterUuid}, callback) =>
    @uuidAliasResolver.resolve emitterUuid, (error, emitterUuid) =>
      return callback error if error?

      @_find {emitterUuid, deleted: {$ne: true}}, callback

  emitterListForType: ({emitterUuid, type}, callback) =>
    @uuidAliasResolver.resolve emitterUuid, (error, emitterUuid) =>
      return callback error if error?

      @_find {emitterUuid, type, deleted: {$ne: true}}, callback

  exists: ({subscriberUuid, emitterUuid, type}, callback) =>
    return callback @_createUserError 'Missing subscriberUuid', 422 unless subscriberUuid?
    return callback @_createUserError 'Missing emitterUuid', 422 unless emitterUuid?
    return callback @_createUserError 'Missing type', 422 unless type?
    return callback @_createUserError 'Invalid type', 422 unless type in SubscriptionManager.TYPES

    @uuidAliasResolver.resolve emitterUuid, (error, emitterUuid) =>
      return callback error if error?
      @uuidAliasResolver.resolve subscriberUuid, (error, subscriberUuid) =>
        return callback error if error?

        query = {subscriberUuid, emitterUuid, type}
        @datastore.findOne query, {_id: true}, (error, subscription) =>
          return callback error if error?
          callback null, subscription?

  markAllAsDeleted: ({emitterUuid, subscriberUuid}, callback) =>
    return callback @_createUserError 'Needs at least one of emitterUuid, subscriberUuid', 422 unless emitterUuid? || subscriberUuid?

    @_resolve emitterUuid, (error, emitterUuid) =>
      return callback error if error?
      @_resolve subscriberUuid, (error, subscriberUuid) =>
        return callback error if error?
        query = _.pickBy {emitterUuid, subscriberUuid}
        @datastore.update query, {$set: {deleted: true}}, callback

  remove: ({subscriberUuid, emitterUuid, type}, callback) =>
    return callback @_createUserError 'Missing subscriberUuid', 422 unless subscriberUuid?
    return callback @_createUserError 'Missing emitterUuid', 422 unless emitterUuid?
    return callback @_createUserError 'Missing type', 422 unless type?
    return callback @_createUserError 'Invalid type', 422 unless type in SubscriptionManager.TYPES

    @uuidAliasResolver.resolve emitterUuid, (error, emitterUuid) =>
      return callback @_createUserError error.message if error?
      @uuidAliasResolver.resolve subscriberUuid, (error, subscriberUuid) =>
        return callback @_createUserError error.message if error?
        @datastore.remove {subscriberUuid,emitterUuid,type}, callback

  subscriberList: ({subscriberUuid}, callback) =>
    @uuidAliasResolver.resolve subscriberUuid, (error, subscriberUuid) =>
      return callback error if error?
      @_find {subscriberUuid}, callback

  subscriberListForType: ({subscriberUuid, type}, callback) =>
    @uuidAliasResolver.resolve subscriberUuid, (error, subscriberUuid) =>
      return callback error if error?
      @_find {subscriberUuid, type}, callback

  _createUserError: (message, code) =>
    error = new Error message
    error.code = code || 500
    return error

  _find: (query, callback) =>
    @datastore.find query, SubscriptionManager.PROJECTION, callback

  _resolve: (alias, callback) =>
    return callback() if _.isEmpty alias
    @uuidAliasResolver.resolve alias, callback

module.exports = SubscriptionManager
