module 'Unit: EventStream'

fakeStore =
  find: sinon.stub()
  getById: sinon.stub()
  pushPayload: sinon.spy()

eventStream = ETahi.EventStream.create(init: (-> null), store: fakeStore)
sinon.stub(eventStream, "createOrUpdateTask", -> null)


test 'action:created without a task will call pushPayload with the data', ->
    action: 'created'
    meta: null
    foo:
      id: 1

  eventStream.msgResponse({data: (JSON.stringify data)})
  ok(fakeStore.pushPayload.calledWith({foo: {id: 1}}))

test  'action:created with a task will call createOrUpdateTask with the action and data', ->
  data =
    action: 'created'
    meta: null
    task:
      id: 1

  eventStream.msgResponse({data: (JSON.stringify data)})
  ok(eventStream.createOrUpdateTask.calledWith('created', {task: {id: 1}}))

test 'action:updated with a task will call createOrUpdateTask with the action and data', ->
  data =
    action: 'updated'
    meta: null
    task:
      id: 1

  eventStream.msgResponse({data: (JSON.stringify data)})
  ok(eventStream.createOrUpdateTask.calledWith('updated', {task: {id: 1}}))

test 'action:destroy will try to delete the record from the store', ->
  task =
    deleteRecord: sinon.stub()
    triggerLater: -> null
  fakeStore.findTask = () -> task

  data =
    action: 'destroy'
    meta: null
    task_ids: [1]

  eventStream.msgResponse({data: (JSON.stringify data)})
  ok(task.deleteRecord.called)

test 'with a meta key in the payload it finds the specified model if its not in the store', ->
  data =
    action: 'created'
    task:
      id: 1
    meta:
      model_name: 'Comment'
      id: 1

  eventStream.msgResponse({data: (JSON.stringify data)})
  ok(fakeStore.find.calledWith('Comment', 1))
