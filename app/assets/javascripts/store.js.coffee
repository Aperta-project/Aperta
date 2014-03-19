# http://emberjs.com/guides/models/using-the-store/

ETahi.Store = DS.Store.extend
  # Override the default adapter with the `DS.ActiveModelAdapter` which
  # is built to work nicely with the ActiveModel::Serializers gem.
  adapter: '-active-model'


ETahi.TaskSerializer = DS.ActiveModelSerializer.extend
  extractSingle: (store, primaryType, payload, recordId, requestType) ->
    payload = @normalizePayload(primaryType, payload)
    primaryTypeName = primaryType.typeKey
    primaryRecord = undefined
    debugger
    for prop of payload
      typeName = @typeForRoot(prop)
      type = store.modelFor(typeName)

      if payload[prop].parent_type == 'task'
        isPrimary = true
        primaryType = type
      else
        isPrimary = type.typeKey is primaryTypeName

      # legacy support for singular resources
      if isPrimary and Ember.typeOf(payload[prop]) isnt "array"
        primaryRecord = @normalize(primaryType, payload[prop], prop)
        continue

      #jshint loopfunc:true
      for hash in payload[prop]
        hash.foobar = 'hello!'
        # custom code starts here
        typeName = if hash.type
          @typeForRoot hash.type
        else
          @typeForRoot prop
        # custom code ends here
        type = store.modelFor(typeName)
        typeSerializer = store.serializerFor(type)
        hash = typeSerializer.normalize(type, hash, prop)
        isFirstCreatedRecord = isPrimary and not recordId and not primaryRecord
        isUpdatedRecord = isPrimary and coerceId(hash.id) is recordId

        # find the primary record.
        #
        # It's either:
        # * the record with the same ID as the original request
        # * in the case of a newly created record that didn't have an ID, the first
        #   record in the Array
        if isFirstCreatedRecord or isUpdatedRecord
          primaryRecord = hash
        else
          store.push typeName, hash

    primaryRecord

ETahi.PaperSerializer = DS.ActiveModelSerializer.extend
  normalizePayload: (primaryType, payload) ->
    tasks = payload.tasks
    taskHash = _.reduce(tasks, (memo, task) ->
      memo[task.id] = task
      memo
    , {})
    for phase in payload.phases
      taskObjs = []
      for taskId in phase.task_ids
        taskObjs.push {id: taskId, type: taskHash[taskId].type}
      phase.tasks = taskObjs
      delete phase.task_ids

    payload

  extractSingle: (store, primaryType, payload, recordId, requestType) ->
    payload = @normalizePayload(primaryType, payload)
    primaryTypeName = primaryType.typeKey
    primaryRecord = undefined
    for prop of payload
      typeName = @typeForRoot(prop)
      type = store.modelFor(typeName)
      isPrimary = type.typeKey is primaryTypeName

      # legacy support for singular resources
      if isPrimary and Ember.typeOf(payload[prop]) isnt "array"
        primaryRecord = @normalize(primaryType, payload[prop], prop)
        continue

      #jshint loopfunc:true
      for hash in payload[prop]
        hash.foobar = 'hello!'
        # custom code starts here
        typeName = if hash.type
          @typeForRoot hash.type
        else
          @typeForRoot prop
        # custom code ends here
        type = store.modelFor(typeName)
        typeSerializer = store.serializerFor(type)
        hash = typeSerializer.normalize(type, hash, prop)
        isFirstCreatedRecord = isPrimary and not recordId and not primaryRecord
        isUpdatedRecord = isPrimary and coerceId(hash.id) is recordId

        # find the primary record.
        #
        # It's either:
        # * the record with the same ID as the original request
        # * in the case of a newly created record that didn't have an ID, the first
        #   record in the Array
        if isFirstCreatedRecord or isUpdatedRecord
          primaryRecord = hash
        else
          store.push typeName, hash

    primaryRecord


