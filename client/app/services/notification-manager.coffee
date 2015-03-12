`import Ember from 'ember'`

NotificationManager = Ember.Service.extend

  eventStream: Ember.inject.service("event-stream")
  # TODO: remove this once store is a service ember 1.11
  store: (-> Tahi.__container__.lookup("store:main")).property()

  actionNames: []
  actionNotification: null

  setup: (actionNames) ->
    @set("actionNames", actionNames)

  reset: ->
    @setProperties(actionNames: [], actionNotification: null)

  replayEvents: ->
    eventStream = @get("eventStream")
    @get('store').all("event").forEach (event) ->
      eventStream.emitEvent(event, "afterRender")

  notify: (actionName) ->
    return if Ember.isPresent(@get("actionNotification"))
    @set("actionNotification", @get("actionNames").find((name) -> actionName == name))

  events: (->
    actionNotification = @get("actionNotification")
    return [] if Ember.isEmpty(actionNotification)
    @get('store').all('event').filter (event) ->
      event.get("event") == actionNotification
  ).property('actionNotification')

`export default NotificationManager`
