`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`


app = null

module 'Integration: Pusher',
  afterEach: ->
    Ember.run(app, app.destroy)

  beforeEach: ->
    app = startApp()
    $.mockjax({url: '/api/comments/12', status: 204})
    return null # hangs if we return app, so return null

test 'action:created calls fetchById', (assert) ->
  expect(1)
  commentId = 12

  store = getStore()
  sinon.spy(store, "fetchById")

  Ember.run =>
    route = getContainer().lookup("route:application")
    route.router = null # this is needed for ember integration testing when calling internal methods
    route.send("created", type: "comment", id: commentId)

    assert.ok store.fetchById.called, "it fetches the changed object"

test 'action:destroy will delete the task from the store', (assert) ->
  expect(2)

  data =
    type: "task"
    id: 1

  Ember.run =>
    store = getStore()
    store.push('billing-task', id: 1)
    store.push('billing-task', id: 2)
    route = getContainer().lookup("route:application")
    route.router = null # this is needed for ember integration testing when calling internal methods
    route.send("destroyed", data)
    assert.ok (store.getById('billing-task', 1) is null), "deletes the destroyed task"
    assert.ok (store.getById('billing-task', 2) isnt null), "keeps other tasks"
