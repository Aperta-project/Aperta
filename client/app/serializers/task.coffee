`import ApplicationSerializer from 'tahi/serializers/application'`
`import SerializesHasMany from 'tahi/mixins/serializers/serializes-has-many'`

TaskSerializer = ApplicationSerializer.extend SerializesHasMany,
  serializeIntoHash: (data, type, record, options) ->
    root = 'task'
    data[root] = this.serialize(record, options)

  primaryTypeName: (primaryType) ->
    'task'

`export default TaskSerializer`
