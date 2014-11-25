ETahi.TaskSerializer = ETahi.ApplicationSerializer.extend ETahi.SerializesHasMany,
  serializeIntoHash: (data, type, record, options) ->
    root = 'task'
    data[root] = this.serialize(record, options)

  primaryTypeName: (primaryType) ->
    'task'

ETahi.AuthorsTaskSerializer = ETahi.TaskSerializer.extend()
ETahi.TechCheckTaskSerializer = ETahi.TaskSerializer.extend()
