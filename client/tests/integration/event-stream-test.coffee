`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`


app = null
store = null
route = null

module 'Integration: Pusher',
  afterEach: ->
    store = null
    route = null
    Ember.run(app, app.destroy)

  beforeEach: ->
    app = startApp()
    store = getStore()
    route = getContainer().lookup('route:application')
    route.router = null # this is needed for ember integration testing when calling internal methods
    return null # hangs if we return app, so return null

test 'action:created calls fetchById', (assert) ->
  expect(1)
  commentId = 12

  sinon.spy(store, 'fetchById')

  $.mockjax
    url: '/api/comments/12'
    status: 200
    contentType: 'application/json'
    responseText:
      comment:
        id: commentId
        body: 'testing 123'

  Ember.run =>
    route.send('created', type: 'comment', id: commentId)
    assert.ok store.fetchById.called, 'it fetches the changed object'

test 'action:destroy will delete the task from the store', (assert) ->
  expect(2)

  data =
    type: 'task'
    id: 1

  Ember.run =>
    store.push('billing-task', id: 1)
    store.push('billing-task', id: 2)
    route.send('destroyed', data)
    assert.ok (store.getById('billing-task', 1) is null), 'deletes the destroyed task'
    assert.ok (store.getById('billing-task', 2) isnt null), 'keeps other tasks'
