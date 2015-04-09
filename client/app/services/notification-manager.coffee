`import Ember from 'ember'`

NotificationManager = Ember.Service.extend

  # events for paper
  events: []
  # defined on the route
  registeredNotifications: []
  # displays a green banner
  currentNotification: null

  setup: (registeredNotifications, events) ->
    @setProperties
      registeredNotifications: registeredNotifications
      events: events

  teardown: ->
    @setProperties
      events: []
      registeredNotifications: []
      currentNotification: null

  notify: ->
    if Ember.isEmpty(@get("currentNotification"))
      @set("currentNotification", @get("events").firstObject().get("name"))

  dismiss: ->
    events.

`export default NotificationManager`
