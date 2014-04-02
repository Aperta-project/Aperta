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
    for flow in payload.flows
      taskObjs = []
      for taskId in flow.task_ids
        taskObjs.push {id: taskId, type: taskHash[taskId].type}
      flow.tasks = taskObjs
      delete flow.task_ids

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
