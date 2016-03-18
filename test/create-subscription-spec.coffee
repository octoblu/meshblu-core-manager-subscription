mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
SubscriptionManager = require '../src/subscription-manager'

describe 'Create Subscription', ->
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
        @sut.create {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast'}, (error) => done error

      it 'should create a subscription', (done) ->
        @datastore.find {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal [
            {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast'}
          ]
          done()

    describe 'when called with a valid request and the record already exists', ->
      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        @sut.create {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast'}, (@error) => done()

      it 'should have an error with code 304', ->
        expect(@error).to.exist
        expect(@error.code).to.equal 304

      it 'should still have one subscription', (done) ->
        @datastore.find {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal [
            {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast'}
          ]
          done()

    describe 'when called without a subscriberUuid', ->
      beforeEach (done) ->
        @sut.create {emitterUuid:'spiderman',type:'broadcast'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

      it 'should not create a user', (done) ->
        @datastore.find {emitterUuid: 'spiderman', type: 'broadcast'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()

    describe 'when called without a emitterUuid', ->
      beforeEach (done) ->
        @sut.create {subscriberUuid:'superman',type:'broadcast'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

      it 'should not create a user', (done) ->
        @datastore.find {subscriberUuid: 'superman', type: 'broadcast'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()

    describe 'when called without a type', ->
      beforeEach (done) ->
        @sut.create {subscriberUuid:'superman',emitterUuid:'spiderman'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

      it 'should not create a user', (done) ->
        @datastore.find {subscriberUuid:'superman',emitterUuid:'spiderman'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()

    describe 'when called without a valid type', ->
      beforeEach (done) ->
        @sut.create {subscriberUuid:'superman',emitterUuid:'spiderman',type:'superhero'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

      it 'should not create a user', (done) ->
        @datastore.find {subscriberUuid:'superman',emitterUuid:'spiderman',type:'superhero'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()
