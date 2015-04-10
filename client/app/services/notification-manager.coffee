`import Ember from 'ember'`

NotificationManager = Ember.Service.extend

  currentEvent: null

  notify: (event) ->
    if Ember.isEmpty(@get("currentEvent"))
      @set("currentEvent", event)

  dismiss: ->
    @get("currentEvent").destroyRecord()
    @reset()

  reset: ->
    @set("currentEvent", null)

`export default NotificationManager`
