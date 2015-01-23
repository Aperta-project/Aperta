`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import Factory from '../helpers/factory'`
`import EventStream from 'tahi/services/event-stream'`

app = null

setupEventStream = ->
  store = getStore()
  es = EventStream.create
    store: store
    init: ->
  [es, store]

phaseHasTask = (store, {phaseId, taskId}) ->
  phase = store.getById('phase', phaseId)
  task = store.getById('task', taskId)
  phase.get('tasks').contains(task)

taskBelongsToPhase = (store, {phaseId, taskId}) ->
  phase = store.getById('phase', phaseId)
  task = store.getById('task', taskId)
  task.get('phase') == phase

module 'Integration: EventStream',
  teardown: ->
    Ember.run(app, app.destroy)
  setup: ->
    app = startApp()

test 'action:created without a task will put the payload in the store', ->
  expect(1)
  [es, store] = setupEventStream()
  data =
    action: 'created'
    meta: null
    comment:
      id: 1
      body: "HEY"
  Ember.run =>
    es.msgResponse(data)
    comment = store.getById('comment', 1)
    equal comment.get('body'), "HEY", "it puts the correct payload in the store"

test 'action:created will still overwrite existing models', ->
  expect(1)
  [es, store] = setupEventStream()

  data =
    action: 'created'
    meta: null
    comment:
      id: 1
      body: "NEW"
  Ember.run =>
    store.push('comment', id: 1, body: "OLD")
    es.msgResponse(data)
    comment = store.getById('comment', 1)
    equal comment.get('body'), "NEW", "it overrides the current state"

test 'action:destroy will delete the task from the store', ->
  expect(2)
  [es, store] = setupEventStream()

  data =
    action: 'destroyed'
    type: "tasks"
    ids: [1]
  Ember.run =>
    store.push('task', id: 1)
    store.push('task', id: 2)
    es.msgResponse(data)
    ok store.getById('task', 1) is null
    ok store.getById('task', 2) isnt null

test "action:created with a task updates the phase's tasks", ->
  expect(2)
  [es, store] = setupEventStream()

  data =
    action: 'created'
    task:
      id: 10
      phase_id: 1

  Ember.run =>
    store.push('phase', id: 1, title: 'A Phase')
    es.msgResponse(data)
    ok phaseHasTask(store, phaseId: 1, taskId: 10)
    ok taskBelongsToPhase(store, phaseId: 1, taskId: 10)

test "action:updated with a task updates the phase's tasks", ->
  expect(6)
  [es, store] = setupEventStream()
  originalTaskPayload =
    task: {id: 10, phase_id: 1}
    phases: [{id: 1, title: "Phase 1", tasks: [{id: 10, type: "task"}]}]

  data =
    action: 'updated'
    task:
      id: 10
      phase_id: 2

  Ember.run =>
    store.push('phase', id: 2, title: 'Phase 2')
    store.pushPayload('task', originalTaskPayload)
    ok phaseHasTask(store, phaseId: 1, taskId: 10), "phase should have task"
    ok taskBelongsToPhase(store, phaseId: 1, taskId: 10), "task should belong to phase"

    es.msgResponse(data)
    ok phaseHasTask(store, phaseId: 2, taskId: 10), "new phase should have task"
    ok taskBelongsToPhase(store, phaseId: 2, taskId: 10), "task should belong to new phase"
    ok !phaseHasTask(store, phaseId: 1, taskId: 10), "old phase should not have task"
    ok !taskBelongsToPhase(store, phaseId: 1, taskId: 10), "task should not belong to old phase"
