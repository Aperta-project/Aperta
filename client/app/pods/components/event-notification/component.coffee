`import Ember from 'ember'`

EventNotificationComponent = Ember.Component.extend

  notificationManager: Ember.inject.service()
  currentEvent: Ember.computed.alias("notificationManager.currentEvent")
  shouldDisplayNotification: Ember.computed.notEmpty("currentEvent")

  header: (->
    return unless @get("currentEvent")
    @notificationCopy[@get("currentEvent.eventName")].header
  ).property("currentEvent")

  message: (->
    return unless @get("currentEvent")
    @notificationCopy[@get("currentEvent.eventName")].message
  ).property("currentEvent")

  # TODO This should go elsewhere, but for now there's
  # only one instance...
  notificationCopy:
    "paper.revised":
      header: "Yo dawg, your paper was revised"
      message: "Here's a message and stuff about it"

  actions:

    dismiss: (events) ->
      @get("notificationManager").dismiss()


`export default EventNotificationComponent`
