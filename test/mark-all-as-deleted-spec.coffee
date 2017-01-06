{beforeEach, describe, it} = global
{expect} = require 'chai'

mongojs   = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
SubscriptionManager = require '../src/subscription-manager'

describe 'Remove Subscription', ->
  beforeEach (done) ->
    database = mongojs 'subscription-manager-test', ['subscriptions']

    @datastore = new Datastore
      database: database
      collection: 'subscriptions'

    database.subscriptions.remove done

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)
    @sut = new SubscriptionManager {@datastore, @uuidAliasResolver}

  describe '->create', ->
    describe 'when called with a valid request', ->
      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast.sent'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        @sut.markAllAsDeleted {emitterUuid: 'spiderman'}, (error) => done error

      it 'should mark the subscription as deleted', (done) ->
        query = {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast.sent'}
        @datastore.find query, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.have.lengthOf 1
          expect(subscriptions[0]).to.have.property 'deleted', true
          done()

    describe 'when called without a emitterUuid', ->
      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast.sent'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        @sut.markAllAsDeleted {emitterUuid: null}, (@error) => done()

      it 'should have an error', ->
        expect(@error).to.exist
        expect(@error.code).to.deep.equal 422

      it 'should not update the subscription', (done) ->
        query = {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast.sent'}
        @datastore.find query, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.have.lengthOf 1
          expect(subscriptions[0]).not.to.have.property 'deleted'
          done()
