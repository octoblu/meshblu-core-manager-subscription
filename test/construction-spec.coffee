SubscriptionManager = require '../'

describe 'Construction', ->
  describe 'when constructed without a datastore', ->
    it 'should throw an exception', ->
      options = {}
      expect(=> new SubscriptionManager options).to.throw 'datastore is required'

  describe 'when constructed without a uuidAliasResolver', ->
    it 'should throw an exception', ->
      options = {datastore: {}}
      expect(=> new SubscriptionManager options).to.throw 'uuidAliasResolver is required'
