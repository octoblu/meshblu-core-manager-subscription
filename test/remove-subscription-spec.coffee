mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
SubscriptionManager = require '../src/subscription-manager'

describe 'Remove Subscription', ->
  beforeEach (done) ->
    @datastore = new Datastore
      database: mongojs 'subscription-manager-test'
      collection: 'subscriptions'

    @datastore.remove done

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)
    @sut = new SubscriptionManager {@datastore, @uuidAliasResolver}

  describe '->create', ->
    describe 'when called with a valid request', ->
      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast.sent'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        @sut.remove {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast.sent'}, (error) => done error

      it 'should remove a subscription', (done) ->
        @datastore.find {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast.sent'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()

    describe 'when called without a subscriberUuid', ->
      beforeEach (done) ->
        @sut.remove {emitterUuid:'spiderman',type:'broadcast'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

      it 'should not create a user', (done) ->
        @datastore.find {emitterUuid: 'spiderman', type: 'broadcast'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()

    describe 'when called without a emitterUuid', ->
      beforeEach (done) ->
        @sut.remove {subscriberUuid:'superman',type:'broadcast'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

      it 'should not create a user', (done) ->
        @datastore.find {subscriberUuid: 'superman', type: 'broadcast'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()

    describe 'when called without a type', ->
      beforeEach (done) ->
        @sut.remove {subscriberUuid:'superman',emitterUuid:'spiderman'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

      it 'should not create a user', (done) ->
        @datastore.find {subscriberUuid:'superman',emitterUuid:'spiderman'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()

    describe 'when called without a valid type', ->
      beforeEach (done) ->
        @sut.remove {subscriberUuid:'superman',emitterUuid:'spiderman',type:'superhero'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

      it 'should not create a user', (done) ->
        @datastore.find {subscriberUuid:'superman',emitterUuid:'spiderman',type:'superhero'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()
