NotificationHandler = Ember.Mixin.create

  notificationManager: Ember.inject.service()

  replayUnhandledEvents: (->
    notificationManager = @get("notificationManager")
    notificationEvents = @get("notificationEvents")

    @modelFor("paper").get("events").then (events) =>
      event = events.first (events) => notificationEvents.contains(event.get("name"))
      notificationManager.notify(event)
  ).on("activate")

  resetNotification: (->
    @get('notificationManager').reset()
  ).on("deactivate")

`export default NotificationHandler`
