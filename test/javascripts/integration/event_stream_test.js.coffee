setupEventStream = ->
  store = ETahi.__container__.lookup "store:main"
  es = ETahi.EventStream.create
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
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)

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
    es.msgResponse({data: (JSON.stringify data)})
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
    es.msgResponse({data: (JSON.stringify data)})
    comment = store.getById('comment', 1)
    equal comment.get('body'), "NEW", "it overrides the current state"

test 'action:destroy will delete the task from the store', ->
  expect(2)
  [es, store] = setupEventStream()

  data =
    action: 'destroy'
    meta: null
    task_ids: [1]
  Ember.run =>
    store.push('task', id: 1)
    store.push('task', id: 2)
    es.msgResponse({data: (JSON.stringify data)})
    ok store.getById('task', 1).get('isDeleted')
    ok !store.getById('task', 2).get('isDeleted')

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
    es.msgResponse(data: JSON.stringify(data))
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

    es.msgResponse(data: JSON.stringify(data))
    ok phaseHasTask(store, phaseId: 2, taskId: 10), "new phase should have task"
    ok taskBelongsToPhase(store, phaseId: 2, taskId: 10), "task should belong to new phase"
    ok !phaseHasTask(store, phaseId: 1, taskId: 10), "old phase should not have task"
    ok !taskBelongsToPhase(store, phaseId: 1, taskId: 10), "task should not belong to old phase"

test 'with meta information the event stream will ask the server for the specified model', ->
  expect(1)
  [es, store] = setupEventStream()

  data =
    action: 'created'
    task:
      id: 1
    meta:
      model_name: 'Comment'
      id: 1

  server.respondWith 'GET', "/comments/1", [
    200, {"Content-Type": "application/json"}, JSON.stringify {comment: {id: 1, body: "Engage!"}}
  ]

  Ember.run =>
    es.msgResponse(data: JSON.stringify(data))
    ok(_.findWhere(server.requests, {method: "GET", url: "/comments/1"}))
