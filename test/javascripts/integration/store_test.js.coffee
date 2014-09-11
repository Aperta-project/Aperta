module 'Integration: Store',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)

test 'when creating a record, if event stream puts it in the store first, delete it in favor of the newly saved record', ->
  store = ETahi.__container__.lookup "store:main"

  server.respondWith 'POST', "/tasks", [
    200, {"Content-Type": "application/json"}, JSON.stringify {task: {id: 1, body: "FOO"}}
  ]

  Ember.run ->
    newRecord = store.createRecord('task', {body: "FOO"})
    store.push('task', {id: 1, body: "BAR"}) # simulate event stream
    store.push('task', {id: 2, body: "SAVEME"})

    newRecord.save().then (record) ->
      equal(record.get('body'), "FOO", "the record should have the newly saved body, not the one from the existing record.")
      ok(store.find('task', 2),  "the other record should still exist")
