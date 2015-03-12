EventStreamHandler = Ember.Mixin.create

  notificationManager: Ember.inject.service("notification-manager")

  replayUnhandledEvents: (->
    actions = Ember.keys(@_actions).filter (name) -> /^es::(.+)$/.test(name)
    notificationManager = @get('notificationManager')
    notificationManager.setup(actions)
    notificationManager.replayEvents()
  ).on("activate")

  resetNotification: (->
    notificationManager = @get('notificationManager')
    notificationManager.reset()
  ).on("deactivate")

`export default EventStreamHandler`
