`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import Factory from '../helpers/factory'`

app = null

module 'Integration: Pusher',
  afterEach: ->
    Ember.run(app, app.destroy)
  beforeEach: ->
    app = startApp()
    1+1 # hangs if we return app. odd I know...

test 'action:created for anything other than a task will put the payload in the store', ->
  expect(1)
  data =
    comment:
      id: 1
      body: "HEY"
  Ember.run =>
    route = getContainer().lookup("route:application")
    route.router = null # this is needed for ember integration testing when calling internal methods
    route.send("created", data)
    comment = getStore().getById('comment', 1)
    equal comment.get('body'), "HEY", "it puts the correct payload in the store"

test 'action:created for a task will put the payload in the store', ->
  expect(1)
  data =
    task:
      id: 10
      title: "task is here"
      phase_id: 1
  Ember.run =>
    route = getContainer().lookup("route:application")
    route.router = null # this is needed for ember integration testing when calling internal methods
    route.send("created", data)
    task = getStore().findTask(10)
    equal task.get('title'), "task is here", "it puts the correct payload in the store"

test 'action:created will still overwrite existing models', ->
  expect(1)

  data =
    meta: null
    comment:
      id: 1
      body: "NEW"
  Ember.run =>
    store = getStore()
    store.push('comment', id: 1, body: "OLD")
    route = getContainer().lookup("route:application")
    route.router = null # this is needed for ember integration testing when calling internal methods
    route.send("created", data)
    comment = store.getById('comment', 1)
    equal comment.get('body'), "NEW", "it overrides the current state"

test 'action:destroy will delete the task from the store', ->
  expect(2)

  data =
    type: "tasks"
    ids: [1]
  Ember.run =>
    store = getStore()
    store.push('task', id: 1)
    store.push('task', id: 2)
    route = getContainer().lookup("route:application")
    route.router = null # this is needed for ember integration testing when calling internal methods
    route.send("destroyed", data)
    ok store.getById('task', 1) is null
    ok store.getById('task', 2) isnt null
