NotificationHandler = Ember.Mixin.create

  notificationManager: Ember.inject.service()

  replayUnhandledEvents: (->
    notificationManager = @get("notificationManager")
    notificationEvents = @get("notificationEvents")

    @modelFor("paper").get("events").then (events) =>
      if events.length
        event = events.find (e) =>
          notificationEvents.contains(e.get("eventName"))
        notificationManager.notify(event) if event
  ).on("activate")

  resetNotification: (->
    @get('notificationManager').reset()
  ).on("deactivate")

`export default NotificationHandler`
