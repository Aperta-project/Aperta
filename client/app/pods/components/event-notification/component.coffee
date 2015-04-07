`import Ember from 'ember'`

EventNotificationComponent = Ember.Component.extend

  notificationManager: Ember.inject.service()
  events: Ember.computed.alias("notificationManager.events")
  hasNotification: Ember.computed.notEmpty("events")

  header: "A new version of the manuscript is now available. Take a look below"
  message: "some smaller message that will roll up at some point"

  actions:

    dismiss: (events) ->
      Ember.RSVP.all(events.map (e) -> e.destroyRecord()).then =>
        @get("notificationManager").dismiss()

`export default EventNotificationComponent`
