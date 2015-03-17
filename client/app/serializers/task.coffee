`import ApplicationSerializer from 'tahi/serializers/application'`

TaskSerializer = ApplicationSerializer.extend
  serializeIntoHash: (data, type, record, options) ->
    root = 'task'
    data[root] = this.serialize(record, options)

  primaryTypeName: (primaryType) ->
    'task'

`export default TaskSerializer`
