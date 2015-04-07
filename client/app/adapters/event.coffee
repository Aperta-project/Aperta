`import DS from 'ember-data'`

EventAdapter = DS.ActiveModelAdapter.extend
  pathForType: (type) ->
    "user_inboxes"

`export default EventAdapter`
