mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
SubscriptionManager = require '../src/subscription-manager'

describe 'SubscriptionManager', ->
  beforeEach (done) ->
    @datastore = new Datastore
      database: mongojs 'subscription-manager-test'
      collection: 'subscriptions'

    @datastore.remove done

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)
    @sut = new SubscriptionManager {@datastore, @uuidAliasResolver}

  describe '->list', ->
    describe 'when called with a subscription uuid and has subscriptions', ->
      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rap'
          type: 'hip hop'

        @datastore.insert record, done

      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rock'
          type: 'classical'

        @datastore.insert record, done

      beforeEach (done) ->
        @sut.list {subscriberUuid:'punk rock'}, (error, @subscriptions) => done error

      it 'should have a list of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'punk rock', emitterUuid: 'rap', type: 'hip hop'}
          {subscriberUuid: 'punk rock', emitterUuid: 'rock', type: 'classical'}
        ]

    describe 'when called with a subscription uuid and has different subscriptions', ->
      beforeEach (done) ->
        record =
          subscriberUuid: 'jazz'
          emitterUuid: 'alternative rock'
          type: 'dubstep'

        @datastore.insert record, done

      beforeEach (done) ->
        record =
          subscriberUuid: 'jazz'
          emitterUuid: 'alternative rock'
          type: 'dubstep'

        @datastore.insert record, done

      beforeEach (done) ->
        @sut.list {subscriberUuid:'jazz'}, (error, @subscriptions) => done error

      it 'should have a list of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'jazz', emitterUuid: 'alternative rock', type: 'dubstep'}
          {subscriberUuid: 'jazz', emitterUuid: 'alternative rock', type: 'dubstep'}
        ]

  describe '->listForType', ->
    describe 'when called with a subscription uuid and has subscriptions', ->
      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rap'
          type: 'hip hop'

        @datastore.insert record, done

      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rock'
          type: 'classical'

        @datastore.insert record, done

      beforeEach (done) ->
        @sut.listForType {subscriberUuid: 'punk rock', type: 'classical'}, (error, @subscriptions) => done error

      it 'should have a list of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'punk rock', emitterUuid: 'rock', type: 'classical'}
        ]
