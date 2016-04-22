mongojs = require 'mongojs'
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

  describe '->exists', ->
    describe 'when called with a valid request', ->
      beforeEach (done) ->
        subscription = {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast.sent'}
        @datastore.insert subscription, done

      beforeEach (done) ->
        @sut.exists {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast.sent'}, (error, @exists) => done error

      it 'should exist', ->
        expect(@exists).to.be.true

  describe '->exists', ->
    describe 'when called with a non-existent record', ->
      beforeEach (done) ->
        @sut.exists {subscriberUuid:'superman-2', emitterUuid: 'spiderman', type:'broadcast.sent'}, (error, @exists) => done error

      it 'should not exist', ->
        expect(@exists).to.be.false

    describe 'when called without a subscriberUuid', ->
      beforeEach (done) ->
        @sut.exists {emitterUuid:'spiderman',type:'broadcast'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

    describe 'when called without a emitterUuid', ->
      beforeEach (done) ->
        @sut.exists {subscriberUuid:'superman',type:'broadcast'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

    describe 'when called without a type', ->
      beforeEach (done) ->
        @sut.exists {subscriberUuid:'superman',emitterUuid:'spiderman'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422

    describe 'when called without a valid type', ->
      beforeEach (done) ->
        @sut.exists {subscriberUuid:'superman',emitterUuid:'spiderman',type:'superhero'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.code).to.deep.equal 422
