`import Ember from 'ember'`

EventNotificationComponent = Ember.Component.extend

  notificationManager: Ember.inject.service()
  currentEvent: Ember.computed.alias("notificationManager.currentEvent")
  shouldDisplayNotification: Ember.computed.notEmpty("currentEvent")

  header: (->
    notificationCopyFor[@get("currentEvent.name")].header
  ).property("currentEvent")

  message: (->
    notificationCopy[@get("currentEvent.name")].message
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
