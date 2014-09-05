module 'Unit: EventStream'

fakeStore =
  find: sinon.stub()
  getById: sinon.stub()
  pushPayload: sinon.spy()

eventStream = ETahi.EventStream.create(init: (-> null), store: fakeStore)
fakeFetch = sinon.stub(eventStream, 'fetchRecords')

test 'action:created will call fetchRecords', ->
  data =
    action: 'created'
    type: 'foo'
    id: 1
    records_to_load: [{type: 'bar', id: 5}]

  eventStream.msgResponse({data: (JSON.stringify data)})
  ok(fakeFetch.calledWith([{type: 'bar', id: 5}]))

test 'action:updated will call fetchRecords', ->
  data =
    action: 'updated'
    type: 'foo'
    id: 1
    records_to_load: [{type: 'bar', id: 5}]

  eventStream.msgResponse({data: (JSON.stringify data)})
  ok(fakeFetch.calledWith([{type: 'bar', id: 5}]))

test 'action:destroyed will try to delete the record from the store', ->
  task =
    deleteRecord: sinon.stub()
    triggerLater: -> null
  fakeStore.findTask = () -> task

  data =
    action: 'destroyed'
    task_ids: [1]

  eventStream.msgResponse({data: (JSON.stringify data)})
  ok(task.deleteRecord.called)
