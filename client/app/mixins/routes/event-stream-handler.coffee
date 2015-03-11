EventStreamHandler = Ember.Mixin.create

  replayUnhandledEvents: (->
    eventStream = @get("eventStream")
    @store.all("event").forEach (event) ->
      eventStream.emitEvent(event, "afterRender")
  ).on("activate")

`export default EventStreamHandler`
