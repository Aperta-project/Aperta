describe "Tahi.pubsub", ->
  beforeEach ->
    @tokens = []

  afterEach ->
    for token in @tokens
      Tahi.pubsub.unsubscribe token

  describe "#publish", ->
    context "when the topic has subscribers", ->
      it "returns true", ->
        @tokens.push Tahi.pubsub.subscribe('some:topic', jasmine.createSpy('callback'))
        expect(Tahi.pubsub.publish 'some:topic').toEqual true

      it "calls all subscribers to the topic", (done) ->
        numberOfCalls = 0

        callback = (topic, args) ->
          expect(topic).toEqual 'some:topic', args: [1, 2, 3, 4]
          expect(args).toEqual [1, 2, 3]
          if ++numberOfCalls == 2
            done()

        @tokens.push Tahi.pubsub.subscribe('some:topic', callback)
        @tokens.push Tahi.pubsub.subscribe('some:topic', callback)
        Tahi.pubsub.publish 'some:topic', [1, 2, 3]

      it "calls subscribers asynchronously", (done) ->
        publishCalled = false
        callback = ->
          expect(publishCalled).toEqual true
          done()

        @tokens.push Tahi.pubsub.subscribe('some:topic', callback)
        Tahi.pubsub.publish 'some:topic'
        publishCalled = true

    context "when the topic has no subscribers", ->
      it "returns false", ->
        expect(Tahi.pubsub.publish 'no:topic').toEqual false

  describe "#unsubscribe", ->
    it "removes the callback", (done) ->
      callback = jasmine.createSpy 'callback'

      token = Tahi.pubsub.subscribe 'some:event', callback
      Tahi.pubsub.unsubscribe token
      Tahi.pubsub.publish 'some:event'
      setTimeout (->
        expect(callback).not.toHaveBeenCalled()
        done()
      ), 10
