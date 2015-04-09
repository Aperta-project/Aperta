EventStreamHandler = Ember.Mixin.create

  notificationManager: Ember.inject.service()

  replayUnhandledEvents: (->
    notificationManager = @get("notificationManager")
    registeredNotifications = @get("registeredNotifications")

    relevantEvents = @modelFor("paper").get("events").filter (events) =>
      registeredNotifications.contains(event.get("name"))

    relevantEvents.then (events) =>
      notificationManager.setup(events)
      notificationManager.notify()

  ).on("activate")

  resetNotification: (->
    @get('notificationManager').teardown()
  ).on("deactivate")

`export default EventStreamHandler`
