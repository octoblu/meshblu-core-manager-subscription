{beforeEach, describe, it} = global
{expect} = require 'chai'

mongojs = require 'mongojs'
Datastore = require 'meshblu-core-datastore'
SubscriptionManager = require '../src/subscription-manager'

describe 'List Subscriptions', ->
  beforeEach (done) ->
    database = mongojs 'subscription-manager-test', ['subscriptions']
    @datastore = new Datastore
      database: database
      collection: 'subscriptions'

    database.subscriptions.remove done

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)
    @sut = new SubscriptionManager {@datastore, @uuidAliasResolver}

  describe '->subscriberList', ->
    describe 'when called with a subscriberUuid and has subscriptions', ->
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
        @sut.subscriberList {subscriberUuid:'punk rock'}, (error, @subscriptions) => done error

      it 'should have a subscriberList of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'punk rock', emitterUuid: 'rap', type: 'hip hop'}
          {subscriberUuid: 'punk rock', emitterUuid: 'rock', type: 'classical'}
        ]

    describe 'when called with a subscriberUuid and has deleted subscriptions', ->
      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rap'
          type: 'hip hop'
          deleted: true

        @datastore.insert record, done

      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rock'
          type: 'classical'
          deleted: true
          cool: true

        @datastore.insert record, done

      beforeEach (done) ->
        @sut.subscriberList {subscriberUuid:'punk rock'}, (error, @subscriptions) => done error

      it 'should have a subscriberList of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'punk rock', emitterUuid: 'rap', type: 'hip hop'}
          {subscriberUuid: 'punk rock', emitterUuid: 'rock', type: 'classical'}
        ]

    describe 'when called with a subscriberUuid and has different subscriptions', ->
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
        @sut.subscriberList {subscriberUuid:'jazz'}, (error, @subscriptions) => done error

      it 'should have a subscriberList of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'jazz', emitterUuid: 'alternative rock', type: 'dubstep'}
          {subscriberUuid: 'jazz', emitterUuid: 'alternative rock', type: 'dubstep'}
        ]

  describe '->subscriberListForType', ->
    describe 'when called with a subscriberUuid and has subscriptions', ->
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
        @sut.subscriberListForType {subscriberUuid: 'punk rock', type: 'classical'}, (error, @subscriptions) => done error

      it 'should have a subscriberList of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'punk rock', emitterUuid: 'rock', type: 'classical'}
        ]

  describe '->emitterList', ->
    describe 'when called with a emitterUuid and has subscriptions', ->
      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rap'
          type: 'hip hop'

        @datastore.insert record, done

      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rap'
          type: 'classical'

        @datastore.insert record, done

      beforeEach (done) ->
        @sut.emitterList {emitterUuid:'rap'}, (error, @subscriptions) => done error

      it 'should have a emitterList of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'punk rock', emitterUuid: 'rap', type: 'hip hop'}
          {subscriberUuid: 'punk rock', emitterUuid: 'rap', type: 'classical'}
        ]

    describe 'when called with a emitterUuid and has different subscriptions', ->
      beforeEach (done) ->
        record =
          subscriberUuid: 'rap'
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
        @sut.emitterList {emitterUuid:'alternative rock'}, (error, @subscriptions) => done error

      it 'should have a emitterList of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'rap', emitterUuid: 'alternative rock', type: 'dubstep'}
          {subscriberUuid: 'jazz', emitterUuid: 'alternative rock', type: 'dubstep'}
        ]

    describe 'when a subscription is marked as deleted', ->
      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rap'
          type: 'classical'
          deleted: true

        @datastore.insert record, done

      beforeEach (done) ->
        @sut.emitterList {emitterUuid:'rap'}, (error, @subscriptions) => done error

      it 'should not yield and subscriptions', ->
        expect(@subscriptions).to.be.empty

  describe '->emitterListForType', ->
    describe 'when called with a emitterUuid and has subscriptions', ->
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
        @sut.emitterListForType {emitterUuid: 'rock', type: 'classical'}, (error, @subscriptions) => done error

      it 'should have a emitterList of subscriptions', ->
        expect(@subscriptions).to.deep.equal [
          {subscriberUuid: 'punk rock', emitterUuid: 'rock', type: 'classical'}
        ]

    describe 'when a subscription is marked as deleted', ->
      beforeEach (done) ->
        record =
          subscriberUuid: 'punk rock'
          emitterUuid: 'rock'
          type: 'classical'
          deleted: true

        @datastore.insert record, done

      beforeEach (done) ->
        @sut.emitterListForType {emitterUuid: 'rock', type: 'classical'}, (error, @subscriptions) => done error

      it 'should not yield the subscription', ->
        expect(@subscriptions).to.be.empty
