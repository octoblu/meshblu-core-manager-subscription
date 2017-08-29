mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
SubscriptionManager = require '../src/subscription-manager'

describe 'Remove Subscriptions', ->
  beforeEach (done) ->
    database = mongojs 'subscription-manager-test', ['subscriptions']
    @datastore = new Datastore
      database: database
      collection: 'subscriptions'

    database.subscriptions.remove done

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)
    @sut = new SubscriptionManager {@datastore, @uuidAliasResolver}

  describe '->removeMany', ->
    describe 'when called with a valid request', ->
      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast.sent'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'batman', type:'broadcast.sent'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        @sut.removeMany {subscriberUuid:'superman'}, (error) => done error

      it 'should remove a subscription', (done) ->
        @datastore.find {subscriberUuid: 'superman'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()

    describe 'when filtering by emitterUuid', ->
      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast.sent'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'batman', type:'broadcast.sent'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        @sut.removeMany {subscriberUuid:'superman', emitterUuid: 'spiderman'}, (error) => done error

      it 'should remove a subscription', (done) ->
        @datastore.find {subscriberUuid: 'superman'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions.length).to.equal 1
          done()

    describe 'when filtering by type', ->
      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast.sent'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'batman', type:'broadcast.received'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        @sut.removeMany {subscriberUuid:'superman', type: 'broadcast.received'}, (error) => done error

      it 'should remove a subscription', (done) ->
        @datastore.find {subscriberUuid: 'superman'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions.length).to.equal 1
          done()

    describe 'when called without a subscriberUuid', ->
      beforeEach (done) ->
        @sut.removeMany {emitterUuid:'spiderman',type:'broadcast'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

    describe 'when called without a valid type', ->
      beforeEach (done) ->
        @sut.removeMany {subscriberUuid:'superman',emitterUuid:'spiderman',type:'superhero'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422
