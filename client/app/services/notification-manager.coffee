`import Ember from 'ember'`

NotificationManager = Ember.Service.extend

  eventStream: Ember.inject.service("event-stream")
  # TODO: remove this once store is a service ember-data#beta-16
  store: (-> @container.lookup("store:main")).property()

  actionNames: []
  actionNotification: null

  setup: (actionNames) ->
    @set("actionNames", actionNames)

  reset: ->
    @set("actionNames", [])
    @dismiss()

  dismiss: ->
    @set("actionNotification", null)

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
      event.get("name") == actionNotification
  ).property('actionNotification')

`export default NotificationManager`
