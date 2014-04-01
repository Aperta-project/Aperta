ETahi.FlowSerializer = DS.ActiveModelSerializer.extend
  extractArray: (store, type, hash) ->
    hash.flows.forEach (flow)->
      flow.id = flow.title.length << (Math.random()*10|0)

    @_super.apply(@, arguments)


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

  relationshipMap: ->
    {
      manyToNone: true
      manyToMany: true
      manyToOne: true
    }

  toSnakeCase: (string)->
    string.replace /([A-Z])/g, ($1)->
      "_" + $1.toLowerCase()

  serializeHasMany: (record, json, relationship) ->
    key = relationship.key
    idsKey = key.substr(0, key.length-1) + "_ids"
    relationshipType = DS.RelationshipChange.determineRelationshipType(record.constructor, relationship)
    if @relationshipMap relationshipType
      json[@toSnakeCase(idsKey)] = Em.get(record, key).mapBy("id")
    return

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
