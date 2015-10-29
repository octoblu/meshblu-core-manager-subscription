SubscriptionManager = require '../src/subscription-manager'

describe 'SubscriptionManager', ->
  beforeEach ->
    @datastore =
      find: sinon.stub()

    @sut = new SubscriptionManager
      datastore: @datastore

  describe '->list', ->
    describe 'when called with a subscription uuid and has subscriptions', ->
      beforeEach (done) ->
        @datastore.find.yields null, [
          {subscriberUuid: 'punk rock', emitterUuid: 'rap', type: 'hip hop'}
          {subscriberUuid: 'punk rock', emitterUuid: 'rock', type: 'classical'}
        ]
        @sut.list 'punk rock', (error, @subscriptions) => done error

      it 'should have a list of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'punk rock', emitterUuid: 'rap', type: 'hip hop'}
          {subscriberUuid: 'punk rock', emitterUuid: 'rock', type: 'classical'}
        ]

    describe 'when called with a subscription uuid and has different subscriptions', ->
      beforeEach (done) ->
        @datastore.find.yields null, [
          {subscriberUuid: 'jazz', emitterUuid: 'alternative rock', type: 'dubstep'}
          {subscriberUuid: 'jazz', emitterUuid: 'alternative rock', type: 'dubstep'}
        ]
        @sut.list 'jazz', (error, @subscriptions) => done error

      it 'should have a list of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'jazz', emitterUuid: 'alternative rock', type: 'dubstep'}
          {subscriberUuid: 'jazz', emitterUuid: 'alternative rock', type: 'dubstep'}
        ]
